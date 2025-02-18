DO $$ BEGIN
 CREATE TYPE "public"."customer_status" AS ENUM('new-lead', 'qualified-lead', 'disqualified-lead', 'nurture', 'open', 'proposal-sent', 'negotiation', 'contract-sent', 'contract-signed', 'closed-won', 'closed-lost', 'on-hold', 'renewal', 'upsell-cross-sell-opportunity', 'pending', 'follow-up', 'research', 'meeting-scheduled');
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "account" (
	"user_id" uuid NOT NULL,
	"type" text NOT NULL,
	"provider" text NOT NULL,
	"providerAccountId" text NOT NULL,
	"refresh_token" text,
	"access_token" text,
	"expires_at" integer,
	"token_type" text,
	"scope" text,
	"id_token" text,
	"session_state" text,
	CONSTRAINT "account_provider_providerAccountId_pk" PRIMARY KEY("provider","providerAccountId")
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "customer" (
	"id" uuid DEFAULT gen_random_uuid() NOT NULL,
	"user" uuid NOT NULL,
	"name" text NOT NULL,
	"created_at" timestamp NOT NULL,
	"modified_at" timestamp NOT NULL,
	"sale_score" integer NOT NULL,
	"savings_rating" integer NOT NULL,
	"status" "customer_status" DEFAULT 'new-lead' NOT NULL,
	"primary_email" text NOT NULL,
	"emails" jsonb NOT NULL,
	"primary_phone" text NOT NULL,
	"phones" jsonb NOT NULL,
	"address" jsonb NOT NULL,
	CONSTRAINT "customer_id_pk" PRIMARY KEY("id")
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "user" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"name" text,
	"email" text,
	"emailVerified" timestamp,
	"image" text
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "verificationToken" (
	"identifier" text NOT NULL,
	"token" text NOT NULL,
	"expires" timestamp NOT NULL,
	CONSTRAINT "verificationToken_identifier_token_pk" PRIMARY KEY("identifier","token")
);
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "account" ADD CONSTRAINT "account_user_id_user_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."user"("id") ON DELETE cascade ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "customer" ADD CONSTRAINT "customer_user_user_id_fk" FOREIGN KEY ("user") REFERENCES "public"."user"("id") ON DELETE cascade ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
CREATE UNIQUE INDEX IF NOT EXISTS "unique_address_person" ON "customer" USING btree ("address","user");--> statement-breakpoint
CREATE UNIQUE INDEX IF NOT EXISTS "user_email_key" ON "user" USING btree ("email");