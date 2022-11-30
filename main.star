nginx_conf_template = read_file("github.com/mieubrisse/my-kurtosis-package/default.conf.tmpl")

def run(args):
    rest_service = add_service(
        "hello-world",
        config = struct(
            image = "vad1mo/hello-world-rest",
            ports = {
                "http": struct(number = 5050, protocol = "TCP"),
            },
        ),
    )

    nginx_conf_data = {
        "HelloWorldIpAddress": rest_service.ip_address,
        "HelloWorldPort": rest_service.ports["http"].number,
    }

    nginx_config_file_artifact = render_templates(
        config = {
            "default.conf": struct(
                template = nginx_conf_template,
                data = nginx_conf_data,
            )
        }
    )

    nginx_count = 1
    if hasattr(args, "nginx_count"):
        nginx_count = args.nginx_count

    for i in range(0, nginx_count):
        add_service(
            "my-nginx-" + str(i),
            config = struct(
                image = "nginx:latest",
                ports = {
                    "http": struct(number = 80, protocol = "TCP"),
                },
                files = {
                    nginx_config_file_artifact: "/etc/nginx/conf.d",
                }
            ),
        )
