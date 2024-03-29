locals {
  dir_sha = base64sha256(join("", [for f in fileset(var.source_dir, "/**") : filebase64sha256("${var.source_dir}/${f}")]))
  triggers = { 
    dir_sha = local.dir_sha
    force = (var.force ? timestamp() : 0)
  }
}

module "builder" {
  source            = "glenngillen/multiline-command/gg"
  version           = "~> 1.0.1"
  
  working_dir = var.source_dir
  command     = var.build_cmd
  triggers    = local.triggers
}

resource "random_id" "this" {
  keepers = {
    dir_sha = local.dir_sha
  }

  byte_length = 8
}

module "archive" {
  source            = "glenngillen/archive/gg"
  version           = "~> 1.0.0"

  triggers    = local.triggers
  output_file = "${path.cwd}/${module.builder.id}-${random_id.this.hex}.zip"
  working_dir = var.source_dir
  source_dir  = var.source_dir
}
module "this" {
  depends_on = [ module.archive ]
  source            = "glenngillen/lambda/aws"
  version           = "~> 1.0.12"

  name       = var.name
  filename   = module.archive.output_file
  handler    = var.handler
  runtime    = var.runtime
  layers     = var.layers
  timeout    = var.timeout
  memory_size = var.memory_size
  source_code_hash = local.dir_sha
  tags = var.tags

  variables = var.variables
}