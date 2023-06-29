# TODO

## Before deploying to production

- [x] Change collection item characteristics from string to nullable json array:
  - [x] Color
  - [x] Palette
  - [x] Contrast
  - [x] Style
  - [x] Body Type
- [x] Change create user-product-categories migration to create collection item
- [x] Updated collection item form to use checkboxes

## After deploying to production

- [ ] Add other sources:
  - [x] Shop2gether
  - [x] Offpremium
  - [ ] Renner
  - [ ] Zara
- [x] Add timezone to all timestamps
- [x] Search for characteristics (collection and all productions)
  - [x] by name
  - [x] by brand
  - [x] by description
- [x] Automatically store product recommendations (more products from the same brand)
- [x] Job to update infos for a product (once a week)
- [x] create closet item migration to store a client online closet: with recomended items
- [x] create stylist client table to store all relationship between clients and stylists
- [ ] Add price migration to log price everytime a product is scraped
- [x] Change create product / product image migration to use images as json/array
- [x] Implement reactive behavior on views (hotwire?)
- [ ] implement en / pt-br translations (i10n)
- [ ] implement error handling
- [ ] implement add product to collection
- [x] implement UI design
- [x] Bug: if searching for a product that already is in the database, nothing happens
