# btop -- system monitor.
# Theme switching creates a symlink at ~/.config/btop/themes/active.theme.
{...}: {
  kernix.theme.hooks = ["btop"];

  programs.btop = {
    enable = true;

    settings = {
      color_theme = "$HOME/.config/btop/themes/active.theme";
      theme_background = false;
      truecolor = true;
      presets = "cpu:1:default,proc:0:default cpu:0:default,mem:0:default,net:0:default cpu:0:block,net:0:tty";
      rounded_corners = true;
      terminal_sync = true;
      graph_symbol = "braille";
      shown_boxes = "cpu mem net proc gpu0";
      update_ms = 100;
      proc_sorting = "cpu direct";
      proc_colors = true;
      proc_gradient = true;
      proc_mem_bytes = true;
      proc_cpu_graphs = true;
      cpu_invert_lower = true;
      show_uptime = true;
      show_cpu_watts = true;
      check_temp = true;
      show_coretemp = true;
      show_cpu_freq = true;
      show_gpu_info = "Auto";
      mem_graphs = true;
      show_swap = true;
      swap_disk = true;
      show_io_stat = true;
      net_auto = true;
      net_sync = true;
      nvml_measure_pcie_speeds = true;
      rsmi_measure_pcie_speeds = true;
      gpu_mirror_graph = true;
      save_config_on_exit = false;
    };
  };
}
