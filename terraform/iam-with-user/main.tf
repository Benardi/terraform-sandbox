terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    pgp = {
      source = "ekristen/pgp"
    }
  }
}

provider "aws" {
  profile = "admin-general"
  region  = "us-east-1"
}

resource "random_id" "identifier" {
  byte_length = 8
}

resource "aws_s3_bucket" "animalpics" {
  bucket = "animal-pics-${random_id.identifier.hex}"
  force_destroy = true
  tags = {
    Name = "AnimalPicsBucket"
  }
}

resource "aws_s3_bucket" "catpics" {
  bucket = "cats-pics-${random_id.identifier.hex}"
  force_destroy = true
  tags = {
    Name = "CatPicsBucket"
  }
}

resource "aws_iam_user" "managed_user" {
  name          = "sally"
  force_destroy = true
}

resource "pgp_key" "user_login_key" {
  name    = aws_iam_user.managed_user.name
  email   = "sally@example.com"
  comment = "PGP Key for managed user"
}

resource "aws_iam_user_login_profile" "user_profile" {
  user                    = aws_iam_user.managed_user.name
  pgp_key                 = pgp_key.user_login_key.public_key_base64
}

resource "aws_iam_user_policy" "allow_all_s3_except_cats" {
  name   = "AllowAllS3ExcepCats"
  user   = aws_iam_user.managed_user.name
  policy = <<-EOF
           {
             "Version": "2012-10-17",
             "Statement": [
               {
                 "Sid": "AllowAllStatement",
                 "Effect": "Allow",
                 "Action": ["s3:*"],
                 "Resource":["arn:aws:s3:::*"]
               },
               {
                 "Sid":"DenyCatsStatement",
                 "Effect": "Deny",
                 "Action": "s3:*",
                 "Resource": ["${aws_s3_bucket.catpics.arn}", "${aws_s3_bucket.catpics.arn}/*"]
               }
                 ]
           }
           EOF

}

resource "aws_iam_user_policy_attachment" "user_policy_attachment" {
  user       = aws_iam_user.managed_user.name
  policy_arn = "arn:aws:iam::aws:policy/IAMUserChangePassword"
}

resource "aws_iam_access_key" "user_access_key" {
  user       = aws_iam_user.managed_user.name
  depends_on = [aws_iam_user.managed_user]
}

data "pgp_decrypt" "user_password_decrypt" {
  ciphertext          = aws_iam_user_login_profile.user_profile.encrypted_password
  ciphertext_encoding = "base64"
  private_key         = pgp_key.user_login_key.private_key
}

output "credentials" {
  value = {
    "key"      = aws_iam_access_key.user_access_key.id
    "secret"   = aws_iam_access_key.user_access_key.secret
    "password" = data.pgp_decrypt.user_password_decrypt.plaintext
  }
  sensitive = true
}
