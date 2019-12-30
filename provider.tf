variable "region" {
	type	= string
	default	= "us-east-1"
}

variable "profile" {
	type	= string
	default	= ""
}

variable "access_key" {
	type	= string
	default	= ""
}

variable "secret_key" {
	type	= string
	default	= ""
}

provider "aws" {
  region	= var.region
  profile	= var.profile
  access_key	= var.access_key
  secret_key	= var.secret_key
}
