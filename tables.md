# Database design

## Product

- id: string
- name: string
- sku: string | null
- brand: string | null
- store: string
- url: string
- store_url: string
- description: text | null
- old_price: decimal(10,2) | null
- price: decimal(10,2)
- installment_quantity: integer | null
- installment_value: decimal(10,2) | null
- available: boolean
- sizes: jsonb array
- images: string array
- created_at: timestamp with timezone
- updated_at: timestamp with timezone

## User

- id: string
- first_name: varchar | null
- last_name: varchar | null
- email: varchar
- password: varchar | null
- picture: varchar | null
- role: enum(stylist | client | admin)
- stylist_id: user.id | null
- created_at: timestamp with timezone
- updated_at: timestamp with timezone

## CollectionItem

- id: string
- stylist_id: user.id
- product_id: product.id
- category: jsonb | null
- color: jsonb | null
- palette: jsonb | null
- contrast: jsonb | null
- style: jsonb | null
- body_type: jsonb | null
- created_at: timestamp with timezone
- updated_at: timestamp with timezone

## StylistClient

- stylist_id: user.id
- client_id: user.id
- created_at: timestamp with timezone
- updated_at: timestamp with timezone

## ClosetItem

- id: string
- owner_id: user.id
- product_id: product.id
- referenced_by: user.id | null
- owned: boolean
- created_at: timestamp with timezone
- updated_at: timestamp with timezone

## Price

- id: string
- product_id: product.id
- old_price: decimal(10,2) | null
- price: decimal(10,2)
- installment_quantity: integer | null
- installment_value: decimal(10,2) | null
- created_at: timestamp with timezone
- updated_at: timestamp with timezone
