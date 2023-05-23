# Database design

## Product

- id: uuid
- name: text
- sku: text
- brand: text
- store: text
- url: text
- store_url: text
- description: text
- old_price: float
- price: float
- installment_quantity: integer
- installment_value: float
- available: boolean
- sizes: json
- images: json
- createdAt: timestamp
- updatedAt: timestamp

## User

- id: uuid
- first_name: varchar
- last_name: varchar
- email: varchar
- password: varchar
- picture: varchar
- role: varchar
- stylistId: uuid
- createdAt: timestamp
- updatedAt: timestamp

## Product Categories

- id: uuid
- userId: uuid
- category: varchar
- color: varchar
- palette: varchar
- contrast: varchar
- style: varchar
- body_type: varchar
- createdAt: timestamp
- updatedAt: timestamp
