resource "aws_iam_role" "iam_role" {
  name = "${var.policy_name}_ecs_instance_role"
  path = "/ecs/"
  assume_role_policy = "${file("ecs-instance-policy/assume-role-policy.json")}"
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "${var.policy_name}_ecs_instance_profile"
  role = "${aws_iam_role.iam_role.name}"
}

resource "aws_iam_role_policy_attachment" "ecs_ec2_role" {
  role       = "${aws_iam_role.iam_role.id}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "ecs_ec2_cloudwatch_role" {
  role       = "${aws_iam_role.iam_role.id}"
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_role_policy_attachment" "ecs_ec2_describe_instances" {
  role       = "${aws_iam_role.iam_role.id}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}
