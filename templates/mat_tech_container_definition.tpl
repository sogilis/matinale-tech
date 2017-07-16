[
  {
    "name": "matinale-tech",
    "image": "${account_id}.dkr.ecr.eu-west-1.amazonaws.com/matinale-tech:${version}",
    "cpu": 100,
    "memory": 128,
    "essential": true,
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 0
      }
    ],
    "environment" : [
        { "name" : "ENV", "value" : "${env}" }
    ]
  }
]
