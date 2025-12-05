# CodeDeploy Deployment Groups for Autoscaling Groups
resource "aws_codedeploy_deployment_group" "backend_dev" {
  app_name              = aws_codedeploy_app.backend.name
  deployment_group_name = "${var.project_name}-backend-dev-dg"
  service_role_arn      = aws_iam_role.codedeploy_role.arn

  autoscaling_groups = [var.backend_dev_asg_name]

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "IN_PLACE"
  }

  load_balancer_info {
    target_group_info {
      name = var.backend_dev_target_group_name
    }
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE", "DEPLOYMENT_STOP_ON_ALARM"]
  }
}

resource "aws_codedeploy_deployment_group" "backend_prod" {
  app_name              = aws_codedeploy_app.backend.name
  deployment_group_name = "${var.project_name}-backend-prod-dg"
  service_role_arn      = aws_iam_role.codedeploy_role.arn

  autoscaling_groups = [var.backend_prod_asg_name]

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "IN_PLACE"
  }

  load_balancer_info {
    target_group_info {
      name = var.backend_prod_target_group_name
    }
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE", "DEPLOYMENT_STOP_ON_ALARM"]
  }
}

resource "aws_codedeploy_deployment_group" "frontend_dev" {
  app_name              = aws_codedeploy_app.frontend.name
  deployment_group_name = "${var.project_name}-frontend-dev-dg"
  service_role_arn      = aws_iam_role.codedeploy_role.arn

  autoscaling_groups = [var.frontend_dev_asg_name]

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "IN_PLACE"
  }

  load_balancer_info {
    target_group_info {
      name = var.frontend_dev_target_group_name
    }
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE", "DEPLOYMENT_STOP_ON_ALARM"]
  }
}

resource "aws_codedeploy_deployment_group" "frontend_prod" {
  app_name              = aws_codedeploy_app.frontend.name
  deployment_group_name = "${var.project_name}-frontend-prod-dg"
  service_role_arn      = aws_iam_role.codedeploy_role.arn

  autoscaling_groups = [var.frontend_prod_asg_name]

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "IN_PLACE"
  }

  load_balancer_info {
    target_group_info {
      name = var.frontend_prod_target_group_name
    }
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE", "DEPLOYMENT_STOP_ON_ALARM"]
  }
}
