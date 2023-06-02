

resource "aws_iam_role" "nodes" {
  name = "eks-node-group-nodes"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
  }
  ]
  }
  POLICY
}
resource "aws_iam_role_policy_attachment" "amazon_eks_worker_node_policy_nodes" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.nodes.name
}
resource "aws_iam_role_policy_attachment" "amazon_eks_cni_policy_nodes" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.nodes.name

}
resource "aws_iam_role_policy_attachment" "amazon_ec2_container_registry_read_only" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.nodes.name
}

resource "aws_eks_node_group" "private-nodes" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "private-nodes"
  node_role_arn   = aws_iam_role.nodes.arn
  subnet_ids = [
    aws_subnet.private_1.id,
    aws_subnet.private_2.id
  ]

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }
  ami_type             = "AL2_x86_64"
  capacity_type        = "ON_DEMAND"
  disk_size            = 20
  force_update_version = false
  instance_types       = ["t3.small"]
  labels = {
    role = "nodes"

  }

  version = "1.26"
  depends_on = [
    aws_iam_role_policy_attachment.amazon_eks_worker_node_policy_nodes,
    aws_iam_role_policy_attachment.amazon_eks_cni_policy_nodes,
    aws_iam_role_policy_attachment.amazon_ec2_container_registry_read_only,

  ]


}