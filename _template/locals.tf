locals {
  name_prefix = "tf-formation-${var.student_id}"

  common_tags = {
    Formation = "terraform"
    Session   = var.session_id
    Student   = var.student_id
    ManagedBy = "terraform"
  }
}