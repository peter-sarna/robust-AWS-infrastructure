# ssh key for instances
resource "aws_key_pair" "ssh_key" {
  key_name = "ssh_key"
  public_key = "${file("${var.PATH_TO_PUB_KEY}")}"
}

#ELB
resource "aws_elb" "elb" {
  name = "elb"
  subnets = ["${aws_subnet.public_subnet_1.id}", "${aws_subnet.public_subnet_2.id}", "${aws_subnet.public_subnet_3.id}"]
  security_groups = ["${aws_security_group.elb_sg.id}"]

  listener {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }

  health_check {
    healthy_threshold = 3
    unhealthy_threshold = 10
    timeout = 10
    target = "HTTP:80/"
    interval = 30
  }

  cross_zone_load_balancing = true
  connection_draining = true
  connection_draining_timeout = 400
  tags = {
    Name = "elb"
  }
}

#user-data for instances

data "template_file" "user_data" {
  template = "${file("nginx_setup.tpl")}"  
}

#Instances

resource "aws_launch_configuration" "web-launchconfig" {
  name_prefix          = "web-launchconfig"
  image_id             = "${data.aws_ami.ubuntu_ami.id}"
  instance_type        = "${var.INSTANCE_TYPE}"
  key_name             = "${aws_key_pair.ssh_key.key_name}"
  security_groups      = ["${aws_security_group.instance_sg.id}"]
  user_data            = "${data.template_file.user_data.rendered}"
  lifecycle {
    create_before_destroy = true # otherwise it's unable to reload tf config
  }
}

resource "aws_autoscaling_group" "web-autoscaling" {
  name                 = "web-autoscaling"
  vpc_zone_identifier  = ["${aws_subnet.public_subnet_1.id}", "${aws_subnet.public_subnet_2.id}", "${aws_subnet.public_subnet_3.id}"]
  launch_configuration = "${aws_launch_configuration.web-launchconfig.name}"
  min_size             = 3
  max_size             = 6
  health_check_grace_period = 300
  health_check_type = "ELB"
  load_balancers = ["${aws_elb.elb.name}"]
  force_delete = true
  
  tag {
      key = "Name"
      value = "ec2_instance"
      propagate_at_launch = true
  }
}

# scale up!

resource "aws_autoscaling_policy" "scaling-up-cpu-policy" {
  name                   = "scaling-up-cpu-policy"
  autoscaling_group_name = "${aws_autoscaling_group.web-autoscaling.name}"
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "1"
  cooldown               = "300"
  policy_type            = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "too-high-cpu-alarm" {
  alarm_name          = "too-high-cpu-usage"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "15"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "40"

  dimensions = {
    "AutoScalingGroupName" = "${aws_autoscaling_group.web-autoscaling.name}"
  }

  actions_enabled = true
  alarm_actions   = ["${aws_autoscaling_policy.scaling-up-cpu-policy.arn}"]
}

# scale down!

resource "aws_autoscaling_policy" "scaling-down-cpu-policy" {
  name                   = "scaling-down-cpu-policy"
  autoscaling_group_name = "${aws_autoscaling_group.web-autoscaling.name}"
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "-1"
  cooldown               = "300"
  policy_type            = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "too-low-cpu-alarm" {
  alarm_name          = "too-low-cpu-usage"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "15"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "20"

  dimensions = {
    "AutoScalingGroupName" = "${aws_autoscaling_group.web-autoscaling.name}"
  }

  actions_enabled = true
  alarm_actions   = ["${aws_autoscaling_policy.scaling-down-cpu-policy.arn}"]
}

