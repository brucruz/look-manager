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
- [ ] Add timezone to all timestamps
- [ ] Search for characteristics
- [ ] Job to update infos for a product (once a week)
- [ ] create closet item migration to store a client online closet: with recomended items
- [ ] create stylist client table to store all relationship between clients and stylists
- [ ] Add price migration to log price everytime a product is scraped
- [ ] Change create product / product image migration to use images as json/array
- [ ] implement job to scrape products every day at 12am
- [ ] Implement reactive behavior on views (hotwire?)
- [ ] implement en / pt-br translations (i10n)
- [x] implement UI design
