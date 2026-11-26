{ config, pkgs, lib, inputs', ... }:
let
  template = pkgs.writeText "sing-box-template.json" (lib.generators.toJSON {} {
    experimental.clash_api.external_controller = "127.0.0.1:9090";
    services = [
      {
        type = "api";
        tag = "s_api";
        listen = "127.0.0.1";
        listen_port = 9091;
      }
    ];

    route = {
      rule_set = [
        {
          type = "local";
          tag = "s_geoip-cn";
          format = "binary";
          path = "${pkgs.sing-geoip}/share/sing-box/rule-set/geoip-cn.srs";
        }
        {
          type = "local";
          tag = "s_geosite-cn";
          format = "binary";
          path = "${pkgs.sing-geosite}/share/sing-box/rule-set/geosite-geolocation-cn.srs";
        }
      ];
      rules = [
        { action = "sniff"; }
        { action =  "hijack-dns"; protocol = "dns"; }
        { domain = [ "sing-portal.ani.llc" ]; outbound = "s_direct"; }
        { wifi_ssid = [ "Anillc's AP" ]; outbound = "s_direct"; }
        { domain_suffix = [ ".kn" ]; outbound = "s_ssh"; }
        { ip_cidr = [ "10.11.0.0/16" "fd11::/16" ]; outbound = "s_ssh"; }
        { rule_set = "s_geoip-cn"; outbound = "s_direct"; }
        { rule_set = "s_geosite-cn"; outbound = "s_direct"; }
        { ip_is_private = true; outbound = "s_direct"; }
        {
          domain = [ "la13-idrive.kagari.org" "sg01-idrive.kagari.org" ];
          outbound = "s_direct";
        }
      ];
      final = "s_out";
      auto_detect_interface = true;
      default_domain_resolver = "s_local";
    };

    dns = {
      servers = [
        { tag = "s_local"; type = "udp"; server = "223.5.5.5"; }
        { tag = "s_local-ap"; type = "local"; }
        { tag = "s_kn-dns"; type = "tcp"; server = "192.0.2.53"; detour = "s_ssh"; }
        {
          tag = "s_cf";
          type = "https";
          server = "1.0.0.1";
          tls.server_name = "cloudflare-dns.com";
          detour = "s_out";
        }
        {
          tag = "s_cf2";
          type = "https";
          server = "1.1.1.1";
          tls.server_name = "cloudflare-dns.com";
          detour = "s_out";
        }
        {
          tag = "s_google";
          type = "https";
          server = "8.8.8.8";
          tls.server_name = "dns.google";
          detour = "s_out";
        }
        {
          tag = "s_quad9";
          type = "https";
          server = "9.9.9.9";
          tls.server_name = "dns.quad9.net";
          detour = "s_out";
        }
      ];
      rules = [
        { wifi_ssid = [ "Anillc's AP" ]; action = "route"; server = "s_local-ap"; }
        { domain_suffix = [ ".kn" ]; action = "route"; server = "s_kn-dns"; }
        { rule_set = "s_geosite-cn"; action = "route"; server = "s_local"; }
        { domain_suffix = "kagari.org"; action = "route"; server = "s_local"; }

        { query_type = [ "A" "AAAA" ]; action = "evaluate"; server = "s_cf"; tag = "r_cf"; }
        { query_type = [ "A" "AAAA" ]; action = "evaluate"; server = "s_cf2"; tag = "r_cf2"; }
        { query_type = [ "A" "AAAA" ]; action = "evaluate"; server = "s_google"; tag = "r_google"; }
        { query_type = [ "A" "AAAA" ]; action = "evaluate"; server = "s_quad9"; tag = "r_quad9"; }

        { match_response = "r_cf"; ip_accept_any = true; action = "respond"; race = true; }
        { match_response = "r_cf2"; ip_accept_any = true; action = "respond"; race = true; }
        { match_response = "r_google"; ip_accept_any = true; action = "respond"; race = true; }
        { match_response = "r_quad9"; ip_accept_any = true; action = "respond"; race = true; }

        { action = "route"; server = "s_cf"; }
      ];
      final = "s_cf";
    };

    inbounds = [
      {
        type = "mixed";
        tag = "s_mixed-in";
        listen = "::";
        listen_port = 7897;
      }
    ];

    outbounds = [
      {
        type = "ssh";
        tag = "s_ssh";
        server = "gw.ani.llc";
        server_port = 222;
        user = "anillc";
        private_key_path = "${config.home.homeDirectory}/.ssh/id_ed25519";
        host_key = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHtrcCHeTAb/QHGkRuGJrZkJgSvkyaSwn3KthLa5SgSJ"
        ];
      }
    ];
  });
in {
  options.singbox.node = lib.mkOption {
    type = lib.types.str;
    description = "machine name reported to sing-portal";
  };

  config = {
    sops.secrets.sing-portal-agent-env.sopsFile = ./secrets.yaml;

    systemd.user.services.sing-box = {
      Unit = {
        Description = "sing-box socks/http proxy";
        After = [ "network-online.target" "sing-box-agent.service" ];
        Wants = [ "network-online.target" ];
      };
      Install.WantedBy = [ "default.target" ];
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.sing-box}/bin/sing-box run -c ${config.xdg.stateHome}/sing-box/config.json";
        Restart = "always";
        RestartSec = 10;
      };
    };

    systemd.user.services.sing-box-agent = {
      Unit = {
        Description = "sing-portal agent";
        After = [ "network-online.target" "sops-nix.service" ];
        Wants = [ "network-online.target" ];
        Before = [ "sing-box.service" ];
      };
      Install.WantedBy = [ "default.target" ];
      Service = {
        Type = "simple";
        ExecStart = lib.concatStringsSep " " [
          "${inputs'.sing-portal.packages.default}/bin/sing-portal-agent"
          "--portal wss://sing-portal.ani.llc"
          "--name ${config.singbox.node}"
          "--template ${template}"
          "--config ${config.xdg.stateHome}/sing-box/config.json"
          "--state-dir ${config.xdg.stateHome}/sing-box"
          "--api-url http://127.0.0.1:9091"
          "--restart-cmd \"systemctl --user restart sing-box\""
        ];
        EnvironmentFile = config.sops.secrets.sing-portal-agent-env.path;
        StateDirectory = "sing-box";
        Restart = "always";
        RestartSec = 10;
      };
    };
  };
}
