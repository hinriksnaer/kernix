# Yazi settings -- openers, file rules, preview, and task configuration.
{
  mgr = {
    ratio = [1 5 4];
    sort_by = "alphabetical";
    sort_sensitive = false;
    sort_reverse = false;
    sort_dir_first = true;
    show_hidden = true;
    show_symlink = true;
    scrolloff = 5;
    linemode = "size";
  };
  preview = {
    tab_size = 2;
    max_width = 600;
    max_height = 900;
    cache_dir = "";
    wrap = "no";
    image_adapter = "auto";
    ueberzug_scale = 1;
    ueberzug_offset = [0 0 0 0];
  };
  opener = {
    edit = [
      {
        run = ''nvim "$@"'';
        block = true;
        "for" = "linux";
      }
    ];
    open = [
      {
        run = ''xdg-open "$@"'';
        desc = "Open";
        orphan = true;
      }
    ];
    reveal = [
      {
        run = ''yazi "$@"'';
        desc = "Reveal in Yazi";
        "for" = "linux";
      }
    ];
    play = [
      {
        run = ''mpv "$@"'';
        orphan = true;
        "for" = "linux";
        desc = "Play with mpv";
      }
    ];
    archive = [
      {
        run = ''ouch decompress "$@"'';
        desc = "Extract here";
      }
      {
        run = ''ouch decompress "$@" --yes'';
        desc = "Extract (overwrite)";
      }
    ];
    image = [
      {
        run = ''imv "$@"'';
        orphan = true;
        desc = "View in imv";
      }
      {
        run = ''xdg-open "$@"'';
        orphan = true;
        desc = "Open with default";
      }
    ];
    pdf = [
      {
        run = ''zathura "$@"'';
        orphan = true;
        desc = "Open in Zathura";
      }
      {
        run = ''xdg-open "$@"'';
        orphan = true;
        desc = "Open with default";
      }
    ];
  };
  open.rules = [
    {
      mime = "text/*";
      use = "edit";
    }
    {
      mime = "application/json";
      use = "edit";
    }
    {
      mime = "application/x-yaml";
      use = "edit";
    }
    {
      mime = "application/toml";
      use = "edit";
    }
    {
      mime = "*/javascript";
      use = "edit";
    }
    {
      mime = "image/*";
      use = "image";
    }
    {
      mime = "video/*";
      use = "play";
    }
    {
      mime = "audio/*";
      use = "play";
    }
    {
      mime = "application/x-tar";
      use = "archive";
    }
    {
      mime = "application/zip";
      use = "archive";
    }
    {
      mime = "application/gzip";
      use = "archive";
    }
    {
      mime = "application/x-7z-compressed";
      use = "archive";
    }
    {
      mime = "application/x-rar";
      use = "archive";
    }
    {
      mime = "application/pdf";
      use = "pdf";
    }
    {
      mime = "inode/directory";
      use = "open";
    }
  ];
  tasks = {
    micro_workers = 10;
    macro_workers = 25;
    bizarre_retry = 5;
    image_alloc = 536870912;
    image_bound = [0 0];
    suppress_preload = false;
  };
  log.enabled = false;
}
