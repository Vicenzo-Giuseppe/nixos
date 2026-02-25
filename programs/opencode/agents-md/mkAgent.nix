{lib}: let
  # These are the base arguments applied when 'default = true'
  defaultArgs = {
    tools = {
      read = true;
      write = true;
      edit = true;
      bash = true;
      grep = true;
      list = true;
      glob = true;
      todoread = true;
      todowrite = true;
      submit_plan = true;
      exa_web_search_exa = true;
      exa_company_research_exa = true;
      exa_crawling_exa = true;
      exa_get_code_context_exa = true;
      exa_deep_researcher_start_exa = true;
      exa_deep_researcher_check_exa = true;
      firecrawl_firecrawl_scrape = true;
      firecrawl_firecrawl_search = true;
      firecrawl_firecrawl_extract = true;
      firecrawl_firecrawl_agent = true;
      github_create_or_update_file = true;
      github_search_repositories = true;
      github_get_file_contents = true;
      github_search_code = true;
      github_search_issues = true;
      github_list_issues = true;
      github_get_pull_request = true;
      github_list_pull_requests = true;
      github_create_pull_request = true;
      github_update_pull_request = true;
      github_get_pull_request_files = true;
      github_get_pull_request_status = true;
      github_update_pull_request_branch = true;
      github_get_pull_request_comments = true;
      github_get_pull_request_reviews = true;
      github_create_pull_request_review = true;
      github_merge_pull_request = true;
      nixos_nixos_search = true;
      nixos_nixos_info = true;
      nixos_nixos_channels = true;
      nixos_nixos_stats = true;
      nixos_home_manager_search = true;
      nixos_home_manager_info = true;
      nixos_home_manager_stats = true;
      nixos_home_manager_list_options = true;
      nixos_home_manager_options_by_prefix = true;
      nixos_darwin_search = true;
      nixos_darwin_info = true;
      nixos_darwin_stats = true;
      nixos_darwin_list_options = true;
      nixos_darwin_options_by_prefix = true;
      nixos_nixos_flakes_stats = true;
      nixos_nixos_flakes_search = true;
      nixos_nixhub_package_versions = true;
      nixos_nixhub_find_version = true;
      "firefox-mcp_list_pages" = true;
      "firefox-mcp_new_page" = true;
      "firefox-mcp_navigate_page" = true;
      "firefox-mcp_select_page" = true;
      "firefox-mcp_take_snapshot" = true;
      "firefox-mcp_click_by_uid" = true;
      "firefox-mcp_fill_by_uid" = true;
      "firefox-mcp_fill_form_by_uid" = true;
      "firefox-mcp_list_network_requests" = true;
      "firefox-mcp_list_console_messages" = true;
      "firefox-mcp_screenshot_page" = true;
      "firefox-mcp_screenshot_by_uid" = true;
      "firefox-mcp_navigate_history" = true;
      "firefox-mcp_accept_dialog" = true;
      "firefox-mcp_dismiss_dialog" = true;
      "firefox-mcp_set_viewport_size" = true;
    };
    permission = {
      bash = {
        mkdir = "allow";
        touch = "allow";
        echo = "allow";
        cat = "allow";
        grep = "allow";
        find = "allow";
        ls = "allow";
        pwd = "allow";
        sed = "allow";
        "*" = "ask";
      };
    };
  };

  # Recursive helper for Block-Style YAML
  toYAMLBlock = indent: attrs: let
    mkLine = k: v: let
      # Ensures "*" is quoted to prevent YAML alias errors
      safeKey =
        if k == "*"
        then ''"*"''
        else k;

      valueStr =
        if builtins.isBool v
        then
          (
            if v
            then "true"
            else "false"
          )
        else if builtins.isAttrs v
        then "\n${toYAMLBlock (indent + "  ") v}"
        else if builtins.isString v
        then ''"${v}"''
        else builtins.toString v;
    in "${indent}${safeKey}: ${valueStr}";
  in
    builtins.concatStringsSep "\n" (lib.mapAttrsToList mkLine attrs);
in {
  # We return the function so it can be used elsewhere
  mkAgent = contentPath: args: let
    useDefault = args.default or false;
    userArgs = builtins.removeAttrs args ["default"];

    finalMeta =
      if useDefault
      then lib.recursiveUpdate defaultArgs userArgs
      else userArgs;

    yamlBlock = toYAMLBlock "" finalMeta;
    actualContent = builtins.readFile contentPath;
  in ''
    ---
    ${yamlBlock}
    ---

    ${actualContent}
  '';
}
