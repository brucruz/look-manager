# TODO

## Before deploying to production

- [ ] Change create product / product image migration to use images as json/array
- [ ] Change create user-product-categories migration to create collection item
- [ ] Add timezone to all timestamps
- [ ] Change collection item characteristics from string to nullable json array:
  - [ ] Category
  - [ ] Color
  - [ ] Palette
  - [ ] Contrast
  - [ ] Style
  - [ ] Body Type
- [ ] Updated collection item form to use checkboxes
- [ ] Add price migration to log price everytime a product is scraped
- [ ] create closet item migration to store a client online closet: with recomended items
- [ ] create stylist client table to store all relationship between clients and stylists

## After deploying to production

- [ ] implement job to scrape products every day at 12am
- [ ] Implement reactive behavior on views (hotwire?)
- [ ] implement UI design
- [ ] implement en / pt-br translations (i10n)
