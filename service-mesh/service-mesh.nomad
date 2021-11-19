job "service-mesh" {
    datacenters = ["dc1"]

    group "counting-service" {
        network {
            mode = "bridge"

            port "count" {
                static = 9003
            }
        }

        service {
            name = "count-api"
            port = "count"

            connect {
                sidecar_service {}
            }

            check {
                expose = true
                name = "api-health"
                type = "http"
                method = "GET"
                path = "/health"
                interval = "2s"
                timeout = "5s"
            }
        }

        task "counting" {
            driver = "exec"

            artifact {
                source = "https://github.com/hashicorp/demo-consul-101/releases/download/0.0.3.1/counting-service_linux_amd64.zip"
                destination = "local"
            }

            env {
                PORT = "${NOMAD_PORT_count}"
            }

            config {
                command = "counting-service_linux_amd64"
            }
        }
    }

    group "dashboard-service" {
        network {
            mode = "bridge"

            port "dashboard" {
                static = 9002
                to = 9002
            }
        }

        service {
            name = "dashboard-api"
            port = "dashboard"

            connect {
                sidecar_service {
                    proxy {
                        upstreams {
                            destination_name = "count-api"
                            local_bind_port = 5000
                        }
                    }
                }
            }

            check {
                name = "api-health"
                type = "http"
                method = "GET"
                path = "/health"
                interval = "2s"
                timeout = "5s"
            }
        }

        task "dashboard" {
            driver = "exec"

            env {
                COUNTING_SERVICE_URL = "http://${NOMAD_UPSTREAM_ADDR_count_api}"
                PORT = "${NOMAD_PORT_dashboard}"
            }

            artifact {
                source = "https://github.com/hashicorp/demo-consul-101/releases/download/0.0.3.1/dashboard-service_linux_amd64.zip"
                destination = "local"
            }

            config {
                command = "dashboard-service_linux_amd64"
            }
        }
    }
}