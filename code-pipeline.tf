#### Here we are creating the Codepipline required for building and deploying code. 
### Typically, I would prefer using a base-image which has all the dependencies, and then only add the latest source code from the branch
#### Which is then passed to Codebuild for building, we update the task 

resource "aws_codepipeline" "image_building" {
  name     = "image-building"
  role_arn = aws_iam_role.codepipeline_role.arn
  artifact_store {
    location = "S3-bucket-name-for-storing-artificats from job"
    type     = "S3"

    encryption_key {
      id   = data.aws_kms_alias.s3kmskey.arn
      type = "KMS"
    }
  }
  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        FullRepositoryId = "example.com/repo-name"
        BranchName       = "main" ### branch u want to deploy
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = "Build_image_for_app" ### In Codebuild, u primarily do docker build, tag and push
      }
    }
  }

  #### Finally we do a deployment, we can either do it in Codebuild directly, in the build phase, but then we are not sure if build
  ### was successful

  #### Since we are using ECS Tasks, we need to first get the task definitions we have currently, and then update them. 
  ### We then force ECS to get new container images

  # aws ecs update-service --cluster cluster_name --service app-container --force-new-deployment

}