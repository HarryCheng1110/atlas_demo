-- Modify "customers" table
ALTER TABLE "public"."customers" ADD COLUMN "is_active" boolean NOT NULL DEFAULT true;
-- Create "product_reviews" table
CREATE TABLE "public"."product_reviews" (
  "id" serial NOT NULL,
  "product_id" integer NOT NULL,
  "customer_id" integer NOT NULL,
  "rating" integer NULL,
  "comment" text NULL,
  "created_at" timestamp NOT NULL DEFAULT now(),
  PRIMARY KEY ("id"),
  CONSTRAINT "fk_review_customer" FOREIGN KEY ("customer_id") REFERENCES "public"."customers" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "fk_review_product" FOREIGN KEY ("product_id") REFERENCES "public"."products" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "product_reviews_rating_check" CHECK ((rating >= 1) AND (rating <= 5))
);
-- Create index "idx_review_product" to table: "product_reviews"
CREATE INDEX "idx_review_product" ON "public"."product_reviews" ("product_id");
