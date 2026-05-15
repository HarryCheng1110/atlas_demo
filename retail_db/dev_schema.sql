-- categories
CREATE TABLE "public"."categories" (
    "id" SERIAL PRIMARY KEY,
    "name" VARCHAR(100) NOT NULL,
    "description" TEXT,
    "created_at" TIMESTAMP DEFAULT NOW() NOT NULL
);

-- products
CREATE TABLE "public"."products" (
    "id" SERIAL PRIMARY KEY,
    "category_id" INTEGER,
    "sku" VARCHAR(50) UNIQUE NOT NULL,
    "name" VARCHAR(200) NOT NULL,
    "description" TEXT,
    "price" DECIMAL(10, 2) NOT NULL,
    "stock_quantity" INTEGER DEFAULT 0 NOT NULL,
    "created_at" TIMESTAMP DEFAULT NOW() NOT NULL,
    "updated_at" TIMESTAMP DEFAULT NOW() NOT NULL,
    CONSTRAINT "fk_category" FOREIGN KEY ("category_id") REFERENCES "public"."categories"("id")
);

-- customers
CREATE TABLE "public"."customers" (
    "id" SERIAL PRIMARY KEY,
    "first_name" VARCHAR(100) NOT NULL,
    "last_name" VARCHAR(100) NOT NULL,
    "email" VARCHAR(255) UNIQUE NOT NULL,
    "phone" VARCHAR(20),
    "created_at" TIMESTAMP DEFAULT NOW() NOT NULL,
    "is_active" BOOLEAN DEFAULT TRUE NOT NULL
);

-- orders
CREATE TABLE "public"."orders" (
    "id" SERIAL PRIMARY KEY,
    "customer_id" INTEGER NOT NULL,
    "order_date" TIMESTAMP DEFAULT NOW() NOT NULL,
    "total_amount" DECIMAL(12, 2) NOT NULL,
    "status" VARCHAR(50) DEFAULT 'PENDING' NOT NULL,
    "shipping_address" TEXT,
    CONSTRAINT "fk_customer" FOREIGN KEY ("customer_id") REFERENCES "public"."customers"("id")
);

-- order_items
CREATE TABLE "public"."order_items" (
    "id" SERIAL PRIMARY KEY,
    "order_id" INTEGER NOT NULL,
    "product_id" INTEGER NOT NULL,
    "quantity" INTEGER NOT NULL,
    "unit_price" DECIMAL(10, 2) NOT NULL,
    CONSTRAINT "fk_order" FOREIGN KEY ("order_id") REFERENCES "public"."orders"("id"),
    CONSTRAINT "fk_product" FOREIGN KEY ("product_id") REFERENCES "public"."products"("id")
);

-- Create index for faster searching
CREATE INDEX "idx_product_name" ON "public"."products" ("name");
CREATE INDEX "idx_order_customer" ON "public"."orders" ("customer_id");
