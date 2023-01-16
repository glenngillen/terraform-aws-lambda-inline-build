# Lambda, with inline building of artefacts

Have you got a Lambda function you want to deploy, but it requires you to
build in and package a bunch of dependecies? Maybe it's some node modules? 
Maybe it's gems for your ruby app? Whatever it is, I've got you covered!

## Usage

Here's an actual example of the way I regularly use it. I user Docker in 
my build command to run `npm install` in a container that matches the same
node version as my target Lambda runtime. The `source_dir` will also serve
as toe working directory, which means `$(pwd)` in the build command will be
whatever is defined by `source_dir`. Once the build completes the `source_dir`
will be compressed and the archive automatically used as the source for
the Lambda:

```hcl
module "lambda" {
  source            = "glenngillen/lambda-inline-build/module"
  version           = "1.0.5"

  name        = "my-function"
  source_dir  = "${path.cwd}/app/my-function"
  handler     = "index.lambda_handler"
  runtime     = "nodejs14.x"
  timeout     = 900
  memory_size = 128

  build_cmd  = <<EOF
docker run -v "$(pwd):/var/task" -w /var/task node:14.20.0-slim npm install
EOF
}
```