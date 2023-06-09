require "nokogiri"
require 'net/http'
require "uri"

class OffpremiumScraperService
  def initialize(url)
    @url = url
  end

  def scrape
    uri = URI.parse(@url)

    uri_path = uri.path
    # get the product id from the url (the last part of the path between the last "-"" and the last "/")
    product_id = uri_path.split("-").last.split("/").first

    response = Net::HTTP.get_response(uri)
    html = response.body

    doc = Nokogiri::HTML(html)

    gatsby_script_loader = doc.css('script[id="gatsby-script-loader"]')
    
    if gatsby_script_loader.present?
      # get all text between `"result":` and `,"staticQueryHashes"`
      json = gatsby_script_loader.text.match(/(?<="result":)(.*)(?=,"staticQueryHashes")/).to_s
      # parse the corresponding JSON
      scraped_product = JSON.parse(json)
    else
      raise "No product found"
    end

    # get the product data
    product_data = scraped_product["serverData"]["product"]

    product = {}
    product["name"] = product_data["seo"]["title"]
    product["sku"] = product_data["gtin"]
    product["description"] = product_data["description"]
    product["brand"] = product_data["brand"]["name"]
    product["store"] = "Off Premium"
    product["url"] = @url
    product["store_url"] = "offpremium.com.br"
    product["currency"] = "R$"
    product["images"] = product_data["image"].map { |image| image["url"] }
    product["old_price"] = product_data["commertialOffers"][0]["listPrice"].to_f
    product["price"] = product_data["commertialOffers"][0]["price"].to_f
    product["installment_quantity"] = product_data["commertialOffers"][0]["installment"]["count"]
    product["installment_value"] = product_data["commertialOffers"][0]["installment"]["value"].to_f
    product["available"] = product_data["offers"]["offers"][0]["availability"] === "http://schema.org/InStock" ? true : false

    @product = Product.create(product)

    @product
  end
end

# example of scraped_product
# {"data"=>
#   {"site"=>
#     {"siteMetadata"=>
#       {"title"=>"OFF Premium",
#        "description"=>"Outlet Farm, Animale, e mais, até 70% off",
#        "titleTemplate"=>"%s | Outlet Farm, Animale, e mais, até 70% off",
#        "siteUrl"=>"https://www.offpremium.com.br"}}},
#  "serverData"=>
#   {"product"=>
#     {"id"=>"1157842",
#      "slug"=>
#       "vestido-de-seda-curto-um-ombro-bufante-verde-summer-07-02-6300-04113-1157842",
#      "seo"=>
#       {"title"=>"Vestido De Seda Curto Um Ombro Bufante",
#        "description"=>"",
#        "canonical"=>
#         "/vestido-de-seda-curto-um-ombro-bufante-verde-summer-07-02-6300-04113/p"},
#      "brand"=>{"name"=>"ANIMALE"},
#      "sku"=>"1157842",
#      "gtin"=>"07.02.6300_04113_3",
#      "name"=>"Verde Summer - 38",
#      "description"=>"",
#      "breadcrumbList"=>
#       {"itemListElement"=>
#         [{"item"=>"/feminino/", "name"=>"Feminino", "position"=>1},
#          {"item"=>"/feminino/vestido/", "name"=>"Vestido", "position"=>2},
#          {"item"=>
#            "/vestido-de-seda-curto-um-ombro-bufante-verde-summer-07-02-6300-04113-1157842/p",
#           "name"=>"Vestido De Seda Curto Um Ombro Bufante",
#           "position"=>3}]},
#      "image"=>
#       [{"url"=>
#          "https://lojaoffpremium.vtexassets.com/arquivos/ids/6369133/07026300_04113_1-VESTIDO-DE-SEDA-CURTO-UM-OMBRO-BUFANTE.jpg?v=1772685731",
#         "alternateName"=>"1"},
#        {"url"=>
#          "https://lojaoffpremium.vtexassets.com/arquivos/ids/6337531/07026300_04113_10-VESTIDO-DE-SEDA-CURTO-UM-OMBRO-BUFANTE.jpg?v=1772685731",
#         "alternateName"=>"10"},
#        {"url"=>
#          "https://lojaoffpremium.vtexassets.com/arquivos/ids/6369160/07026300_04113_2-VESTIDO-DE-SEDA-CURTO-UM-OMBRO-BUFANTE.jpg?v=1772685731",
#         "alternateName"=>"2"},
#        {"url"=>
#          "https://lojaoffpremium.vtexassets.com/arquivos/ids/6369181/07026300_04113_3-VESTIDO-DE-SEDA-CURTO-UM-OMBRO-BUFANTE.jpg?v=1772685731",
#         "alternateName"=>"3"},
#        {"url"=>
#          "https://lojaoffpremium.vtexassets.com/arquivos/ids/6369201/07026300_04113_4-VESTIDO-DE-SEDA-CURTO-UM-OMBRO-BUFANTE.jpg?v=1772685731",
#         "alternateName"=>"4"}],
#      "offers"=>
#       {"lowPrice"=>999.9,
#        "highPrice"=>999.9,
#        "priceCurrency"=>"BRL",
#        "offers"=>
#         [{"availability"=>"https://schema.org/InStock",
#           "price"=>999.9,
#           "priceValidUntil"=>"2024-06-09T15:26:20Z",
#           "priceCurrency"=>"BRL",
#           "itemCondition"=>"https://schema.org/NewCondition",
#           "seller"=>{"identifier"=>"1"},
#           "listPrice"=>1998}]},
#      "categoryId"=>"36",
#      "isVariantOf"=>
#       {"productGroupID"=>"303562",
#        "name"=>"Vestido De Seda Curto Um Ombro Bufante",
#        "variants"=>
#         [{"image"=>
#            [{"url"=>
#               "https://lojaoffpremium.vtexassets.com/arquivos/ids/6369126/07026300_04113_1-VESTIDO-DE-SEDA-CURTO-UM-OMBRO-BUFANTE.jpg?v=1772685731",
#              "alternateName"=>"1"},
#             {"url"=>
#               "https://lojaoffpremium.vtexassets.com/arquivos/ids/6337526/07026300_04113_10-VESTIDO-DE-SEDA-CURTO-UM-OMBRO-BUFANTE.jpg?v=1772685731",
#              "alternateName"=>"10"},
#             {"url"=>
#               "https://lojaoffpremium.vtexassets.com/arquivos/ids/6369152/07026300_04113_2-VESTIDO-DE-SEDA-CURTO-UM-OMBRO-BUFANTE.jpg?v=1772685731",
#              "alternateName"=>"2"},
#             {"url"=>
#               "https://lojaoffpremium.vtexassets.com/arquivos/ids/6369174/07026300_04113_3-VESTIDO-DE-SEDA-CURTO-UM-OMBRO-BUFANTE.jpg?v=1772685731",
#              "alternateName"=>"3"},
#             {"url"=>
#               "https://lojaoffpremium.vtexassets.com/arquivos/ids/6369194/07026300_04113_4-VESTIDO-DE-SEDA-CURTO-UM-OMBRO-BUFANTE.jpg?v=1772685731",
#              "alternateName"=>"4"}],
#           "brand"=>{"name"=>"ANIMALE"},
#           "gtin"=>"07.02.6300_04113_1",
#           "id"=>"1157840",
#           "name"=>"Verde Summer - 34",
#           "slug"=>
#            "vestido-de-seda-curto-um-ombro-bufante-verde-summer-07-02-6300-04113-1157840",
#           "sku"=>"1157840",
#           "attributes"=>[{"value"=>"34", "key"=>"Tamanho"}],
#           "offers"=>
#            {"offers"=>
#              [{"price"=>999.9,
#                "listPrice"=>1998,
#                "availability"=>"https://schema.org/InStock",
#                "seller"=>{"identifier"=>"1"}}]},
#           "commertialOffers"=>
#            [{"sellerId"=>"1",
#              "sellerName"=>"OFF PREMIUM",
#              "price"=>999.9,
#              "listPrice"=>1998,
#              "availableQuantity"=>10000,
#              "installment"=>{"count"=>10, "value"=>99.99}}]},
#          {"image"=>
#            [{"url"=>
#               "https://lojaoffpremium.vtexassets.com/arquivos/ids/6369130/07026300_04113_1-VESTIDO-DE-SEDA-CURTO-UM-OMBRO-BUFANTE.jpg?v=1772685731",
#              "alternateName"=>"1"},
#             {"url"=>
#               "https://lojaoffpremium.vtexassets.com/arquivos/ids/6337529/07026300_04113_10-VESTIDO-DE-SEDA-CURTO-UM-OMBRO-BUFANTE.jpg?v=1772685731",
#              "alternateName"=>"10"},
#             {"url"=>
#               "https://lojaoffpremium.vtexassets.com/arquivos/ids/6369157/07026300_04113_2-VESTIDO-DE-SEDA-CURTO-UM-OMBRO-BUFANTE.jpg?v=1772685731",
#              "alternateName"=>"2"},
#             {"url"=>
#               "https://lojaoffpremium.vtexassets.com/arquivos/ids/6369177/07026300_04113_3-VESTIDO-DE-SEDA-CURTO-UM-OMBRO-BUFANTE.jpg?v=1772685731",
#              "alternateName"=>"3"},
#             {"url"=>
#               "https://lojaoffpremium.vtexassets.com/arquivos/ids/6369198/07026300_04113_4-VESTIDO-DE-SEDA-CURTO-UM-OMBRO-BUFANTE.jpg?v=1772685731",
#              "alternateName"=>"4"}],
#           "brand"=>{"name"=>"ANIMALE"},
#           "gtin"=>"07.02.6300_04113_2",
#           "id"=>"1157841",
#           "name"=>"Verde Summer - 36",
#           "slug"=>
#            "vestido-de-seda-curto-um-ombro-bufante-verde-summer-07-02-6300-04113-1157841",
#           "sku"=>"1157841",
#           "attributes"=>[{"value"=>"36", "key"=>"Tamanho"}],
#           "offers"=>
#            {"offers"=>
#              [{"price"=>999.9,
#                "listPrice"=>1998,
#                "availability"=>"https://schema.org/InStock",
#                "seller"=>{"identifier"=>"1"}}]},
#           "commertialOffers"=>
#            [{"sellerId"=>"1",
#              "sellerName"=>"OFF PREMIUM",
#              "price"=>999.9,
#              "listPrice"=>1998,
#              "availableQuantity"=>10000,
#              "installment"=>{"count"=>10, "value"=>99.99}}]},
#          {"image"=>
#            [{"url"=>
#               "https://lojaoffpremium.vtexassets.com/arquivos/ids/6369133/07026300_04113_1-VESTIDO-DE-SEDA-CURTO-UM-OMBRO-BUFANTE.jpg?v=1772685731",
#              "alternateName"=>"1"},
#             {"url"=>
#               "https://lojaoffpremium.vtexassets.com/arquivos/ids/6337531/07026300_04113_10-VESTIDO-DE-SEDA-CURTO-UM-OMBRO-BUFANTE.jpg?v=1772685731",
#              "alternateName"=>"10"},
#             {"url"=>
#               "https://lojaoffpremium.vtexassets.com/arquivos/ids/6369160/07026300_04113_2-VESTIDO-DE-SEDA-CURTO-UM-OMBRO-BUFANTE.jpg?v=1772685731",
#              "alternateName"=>"2"},
#             {"url"=>
#               "https://lojaoffpremium.vtexassets.com/arquivos/ids/6369181/07026300_04113_3-VESTIDO-DE-SEDA-CURTO-UM-OMBRO-BUFANTE.jpg?v=1772685731",
#              "alternateName"=>"3"},
#             {"url"=>
#               "https://lojaoffpremium.vtexassets.com/arquivos/ids/6369201/07026300_04113_4-VESTIDO-DE-SEDA-CURTO-UM-OMBRO-BUFANTE.jpg?v=1772685731",
#              "alternateName"=>"4"}],
#           "brand"=>{"name"=>"ANIMALE"},
#           "gtin"=>"07.02.6300_04113_3",
#           "id"=>"1157842",
#           "name"=>"Verde Summer - 38",
#           "slug"=>
#            "vestido-de-seda-curto-um-ombro-bufante-verde-summer-07-02-6300-04113-1157842",
#           "sku"=>"1157842",
#           "attributes"=>[{"value"=>"38", "key"=>"Tamanho"}],
#           "offers"=>
#            {"offers"=>
#              [{"price"=>999.9,
#                "listPrice"=>1998,
#                "availability"=>"https://schema.org/InStock",
#                "seller"=>{"identifier"=>"1"}}]},
#           "commertialOffers"=>
#            [{"sellerId"=>"1",
#              "sellerName"=>"OFF PREMIUM",
#              "price"=>999.9,
#              "listPrice"=>1998,
#              "availableQuantity"=>10000,
#              "installment"=>{"count"=>10, "value"=>99.99}}]},
#          {"image"=>
#            [{"url"=>
#               "https://lojaoffpremium.vtexassets.com/arquivos/ids/6369137/07026300_04113_1-VESTIDO-DE-SEDA-CURTO-UM-OMBRO-BUFANTE.jpg?v=1772685731",
#              "alternateName"=>"1"},
#             {"url"=>
#               "https://lojaoffpremium.vtexassets.com/arquivos/ids/6337532/07026300_04113_10-VESTIDO-DE-SEDA-CURTO-UM-OMBRO-BUFANTE.jpg?v=1772685731",
#              "alternateName"=>"10"},
#             {"url"=>
#               "https://lojaoffpremium.vtexassets.com/arquivos/ids/6369163/07026300_04113_2-VESTIDO-DE-SEDA-CURTO-UM-OMBRO-BUFANTE.jpg?v=1772685731",
#              "alternateName"=>"2"},
#             {"url"=>
#               "https://lojaoffpremium.vtexassets.com/arquivos/ids/6369185/07026300_04113_3-VESTIDO-DE-SEDA-CURTO-UM-OMBRO-BUFANTE.jpg?v=1772685731",
#              "alternateName"=>"3"},
#             {"url"=>
#               "https://lojaoffpremium.vtexassets.com/arquivos/ids/6369205/07026300_04113_4-VESTIDO-DE-SEDA-CURTO-UM-OMBRO-BUFANTE.jpg?v=1772685731",
#              "alternateName"=>"4"}],
#           "brand"=>{"name"=>"ANIMALE"},
#           "gtin"=>"07.02.6300_04113_4",
#           "id"=>"1157843",
#           "name"=>"Verde Summer - 40",
#           "slug"=>
#            "vestido-de-seda-curto-um-ombro-bufante-verde-summer-07-02-6300-04113-1157843",
#           "sku"=>"1157843",
#           "attributes"=>[{"value"=>"40", "key"=>"Tamanho"}],
#           "offers"=>
#            {"offers"=>
#              [{"price"=>999.9,
#                "listPrice"=>1998,
#                "availability"=>"https://schema.org/OutOfStock",
#                "seller"=>{"identifier"=>"1"}}]},
#           "commertialOffers"=>
#            [{"sellerId"=>"1",
#              "sellerName"=>"OFF PREMIUM",
#              "price"=>999.9,
#              "listPrice"=>1998,
#              "availableQuantity"=>0,
#              "installment"=>{"count"=>nil, "value"=>nil}}]},
#          {"image"=>
#            [{"url"=>
#               "https://lojaoffpremium.vtexassets.com/arquivos/ids/6369140/07026300_04113_1-VESTIDO-DE-SEDA-CURTO-UM-OMBRO-BUFANTE.jpg?v=1772685731",
#              "alternateName"=>"1"},
#             {"url"=>
#               "https://lojaoffpremium.vtexassets.com/arquivos/ids/6337533/07026300_04113_10-VESTIDO-DE-SEDA-CURTO-UM-OMBRO-BUFANTE.jpg?v=1772685731",
#              "alternateName"=>"10"},
#             {"url"=>
#               "https://lojaoffpremium.vtexassets.com/arquivos/ids/6369167/07026300_04113_2-VESTIDO-DE-SEDA-CURTO-UM-OMBRO-BUFANTE.jpg?v=1772685731",
#              "alternateName"=>"2"},
#             {"url"=>
#               "https://lojaoffpremium.vtexassets.com/arquivos/ids/6369188/07026300_04113_3-VESTIDO-DE-SEDA-CURTO-UM-OMBRO-BUFANTE.jpg?v=1772685731",
#              "alternateName"=>"3"},
#             {"url"=>
#               "https://lojaoffpremium.vtexassets.com/arquivos/ids/6369209/07026300_04113_4-VESTIDO-DE-SEDA-CURTO-UM-OMBRO-BUFANTE.jpg?v=1772685731",
#              "alternateName"=>"4"}],
#           "brand"=>{"name"=>"ANIMALE"},
#           "gtin"=>"07.02.6300_04113_5",
#           "id"=>"1157844",
#           "name"=>"Verde Summer - 42",
#           "slug"=>
#            "vestido-de-seda-curto-um-ombro-bufante-verde-summer-07-02-6300-04113-1157844",
#           "sku"=>"1157844",
#           "attributes"=>[{"value"=>"42", "key"=>"Tamanho"}],
#           "offers"=>
#            {"offers"=>
#              [{"price"=>999.9,
#                "listPrice"=>1998,
#                "availability"=>"https://schema.org/InStock",
#                "seller"=>{"identifier"=>"1"}}]},
#           "commertialOffers"=>
#            [{"sellerId"=>"1",
#              "sellerName"=>"OFF PREMIUM",
#              "price"=>999.9,
#              "listPrice"=>1998,
#              "availableQuantity"=>10000,
#              "installment"=>{"count"=>10, "value"=>99.99}}]}]},
#      "commertialOffers"=>
#       [{"sellerId"=>"1",
#         "sellerName"=>"OFF PREMIUM",
#         "price"=>999.9,
#         "listPrice"=>1998,
#         "availableQuantity"=>10000,
#         "installment"=>{"count"=>10, "value"=>99.99}}],
#      "attributes"=>[{"value"=>"38", "key"=>"Tamanho"}],
#      "videos"=>[],
#      "composition"=>
#       {"name"=>"Composição",
#        "originalName"=>"Composição",
#        "values"=>["100% Seda Forro 100% Viscose"]}}},
#  "pageContext"=>{}}