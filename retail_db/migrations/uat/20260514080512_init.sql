-- Create "customers" table
CREATE TABLE "public"."customers" (
  "id" serial NOT NULL,
  "first_name" character varying(100) NOT NULL,
  "last_name" character varying(100) NOT NULL,
  "email" character varying(255) NOT NULL,
  "phone" character varying(20) NULL,
  "created_at" timestamp NOT NULL DEFAULT now(),
  PRIMARY KEY ("id"),
  CONSTRAINT "customers_email_key" UNIQUE ("email")
);
-- Create "orders" table
CREATE TABLE "public"."orders" (
  "id" serial NOT NULL,
  "customer_id" integer NOT NULL,
  "order_date" timestamp NOT NULL DEFAULT now(),
  "total_amount" numeric(12,2) NOT NULL,
  "status" character varying(50) NOT NULL DEFAULT 'PENDING',
  "shipping_address" text NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "fk_customer" FOREIGN KEY ("customer_id") REFERENCES "public"."customers" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION
);
-- Create index "idx_order_customer" to table: "orders"
CREATE INDEX "idx_order_customer" ON "public"."orders" ("customer_id");
-- Create "categories" table
CREATE TABLE "public"."categories" (
  "id" serial NOT NULL,
  "name" character varying(100) NOT NULL,
  "description" text NULL,
  "created_at" timestamp NOT NULL DEFAULT now(),
  PRIMARY KEY ("id")
);
-- Create "products" table
CREATE TABLE "public"."products" (
  "id" serial NOT NULL,
  "category_id" integer NULL,
  "sku" character varying(50) NOT NULL,
  "name" character varying(200) NOT NULL,
  "description" text NULL,
  "price" numeric(10,2) NOT NULL,
  "stock_quantity" integer NOT NULL DEFAULT 0,
  "created_at" timestamp NOT NULL DEFAULT now(),
  "updated_at" timestamp NOT NULL DEFAULT now(),
  PRIMARY KEY ("id"),
  CONSTRAINT "products_sku_key" UNIQUE ("sku"),
  CONSTRAINT "fk_category" FOREIGN KEY ("category_id") REFERENCES "public"."categories" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION
);
-- Create index "idx_product_name" to table: "products"
CREATE INDEX "idx_product_name" ON "public"."products" ("name");
-- Create "order_items" table
CREATE TABLE "public"."order_items" (
  "id" serial NOT NULL,
  "order_id" integer NOT NULL,
  "product_id" integer NOT NULL,
  "quantity" integer NOT NULL,
  "unit_price" numeric(10,2) NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "fk_order" FOREIGN KEY ("order_id") REFERENCES "public"."orders" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "fk_product" FOREIGN KEY ("product_id") REFERENCES "public"."products" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION
);
