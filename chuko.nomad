job "chuko" {
  datacenters = ["dc1"]
  type = "service"

  group "chuko" {
    count = 1

    network {
       port "http" {
         to = 4000
       }
    }

    service {
      name = "chuko"
      port = "http"
      provider = "nomad"

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.chuko.rule=Host(`chuko.gay`)",
        "traefik.http.routers.chuko.tls=true",
        "traefik.http.routers.chuko.tls.certresolver=letsencrypt"
      ]
    }

    task "chuko" {
      driver = "docker"

      config {
        image = "ghcr.io/okkdev/chuko"
        ports = ["http"]
      }

      env {
        // Generate a new one with `mix phx.gen.secret`
        SECRET_KEY_BASE = "1Lvd0uSlGOblVBx6es3UFyCLxQPh45Vi+VBEbYyIb8D4LEv70VGT+RNK6V2RxYRn"
        PHX_HOST = "chuko.gay"
        DATABASE_PATH = "/app/chuko.db"
      }

      resources {
        cpu = 1000
        memory = 1000
      }
    }
  }
}