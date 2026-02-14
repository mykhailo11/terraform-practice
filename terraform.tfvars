region = "us-east-1"
cidr_block = "10.0.0.0/16"
cidr_block_sn = "10.0.%d.0/24"
environment = "dev"
trusted_host = "213.231.3.155"
key_pair = "default-key-pair"
subnets = [
    {
        public = true
        instances = [
            {
                name = "one"
                fw = [
                    {
                        ingress = true
                        cidr_block = "0.0.0.0/0"
                        from_port = 8000
                        to_port = 8000
                        ip_protocol = "tcp"
                    },
                    {
                        ingress = false
                        ref = "two"
                        from_port = 8000
                        to_port = 8000
                        ip_protocol = "tcp"
                    }
                ]
            }
        ]
    },
    {
        public = false
        instances = [
            {
                name = "two"
                fw = [
                    {
                        ingress = true
                        ref = "one"
                        from_port = 8000
                        to_port = 8000
                        ip_protocol = "tcp"
                    }
                ]
            }
        ]
    }
]