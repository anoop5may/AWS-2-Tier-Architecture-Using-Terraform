# Create EC2 instance for public subnet 1
resource "aws_instance" "web_server1_P18" {
  ami             = "ami-090fa75af13c156b4"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.publicsg_P18.id]
  subnet_id       = aws_subnet.public_subnet1a_P18.id

  user_data = <<-EOF
        #!/bin/bash
        yum update -y
        yum install httpd -y
        systemctl start
        systemctl enable
        echo '<h1>Hello, this is Anoop!</h1>' > /usr/share/nginx/html/index.html
        EOF
}

# Create EC2 instance for public subnet 2
resource "aws_instance" "web_server2_P18" {
  ami             = "ami-090fa75af13c156b4"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.publicsg_P18.id]
  subnet_id       = aws_subnet.public_subnet1b_P18.id

  user_data = <<-EOF
        #!/bin/bash
        yum update -y
        yum install httpd -y
        systemctl start
        systemctl enable 
        echo '<h1>Hey, this is EC2 instance !</h1>' > /usr/share/nginx/html/index.html
        EOF
}
# Create Load balancer
resource "aws_lb" "lb_KP18" {
  name               = "lb-KP18"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.publicsg_P18.id]
  subnets            = [aws_subnet.public_subnet1a_P18.id, aws_subnet.public_subnet1b_P18.id]

  tags = {
    Environment = "KP18"
  }
}

resource "aws_lb_target_group" "P18_target_grp" {
  name     = "project-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.TF_KP18.id
}

# Create ALB listener
resource "aws_lb_listener" "alb_P18" {
  load_balancer_arn = aws_lb.lb_KP18.arn # changed lb_P18 to lb_KP18
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_target.arn
  }
}

#target group
resource "aws_lb_target_group" "lb_target" {
  name       = "target"
  depends_on = [aws_vpc.TF_KP18]
  port       = "80"
  protocol   = "HTTP"
  vpc_id     = aws_vpc.TF_KP18.id
  health_check {
    interval            = 70
    path                = "/var/www/html/index.html"
    port                = 80
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 60
    protocol            = "HTTP"
    matcher             = "200,202"
  }
}
resource "aws_lb_target_group_attachment" "acquire_targets_mki" {
  target_group_arn = aws_lb_target_group.lb_target.arn
  target_id        = aws_instance.web_server1_P18.id
  port             = 80
}
resource "aws_lb_target_group_attachment" "acquire_targets_mkii" {
  target_group_arn = aws_lb_target_group.lb_target.arn
  target_id        = aws_instance.web_server2_P18.id
  port             = 80
}