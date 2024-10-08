#
# Creates a container registry on AWS so that you can publish your Docker images.
#

resource "aws_ecr_repository" "sit722week10" {
  name                 = "sit722week10"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
  
  tags = {
    ResourceGroupName = var.resource_group_name
  }
}