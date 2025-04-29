require 'fastlane/action'
require_relative '../helper/xccov_helper'

module Fastlane
  module Actions
    class XccovViewAction < Action
      def self.run(params)
        cmd = ["xcrun", "xccov", "view"]

        # Handle file viewing options
        if params[:file_list]
          cmd << "--file-list"
        elsif params[:file]
          cmd << "--file" << params[:file]
        end

        # Handle target viewing options
        if params[:only_targets]
          cmd << "--only-targets"
        elsif params[:files_for_target]
          cmd << "--files-for-target" << params[:files_for_target]
        elsif params[:functions_for_file]
          cmd << "--functions-for-file" << params[:functions_for_file]
        end

        # Handle result bundle modes
        if params[:archive]
          cmd << "--archive"
        elsif params[:report]
          cmd << "--report"
        end

        # Handle JSON output
        cmd << "--json" if params[:json]

        # Add the file path at the end
        cmd << params[:file_path]

        # Execute command
        result = Helper::XccovHelper.run_command(cmd.join(" "))

        # Parse JSON if requested
        if params[:json] && result
          require 'json'
          begin
            return JSON.parse(result)
          rescue JSON::ParserError => e
            UI.error("Failed to parse JSON: #{e.message}")
            return result
          end
        end

        return result
      end

      def self.description
        "View code coverage data using Apple's xccov tool"
      end

      def self.authors
        ["crazymanish"]
      end

      def self.return_value
        "Returns the output of the xccov view command (string or parsed JSON)"
      end

      def self.details
        "This action allows you to view code coverage data from .xccovarchive, .xccovreport, or .xcresult files"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :file_path,
                                  env_name: "XCCOV_FILE_PATH",
                               description: "Path to the coverage file (.xccovarchive, .xccovreport, or .xcresult)",
                                  optional: false,
                                      type: String,
                              verify_block: proc do |value|
                                              UI.user_error!("File does not exist at path '#{value}'") unless File.exist?(value)
                                            end),
          FastlaneCore::ConfigItem.new(key: :file_list,
                                  env_name: "XCCOV_FILE_LIST",
                               description: "Display list of files",
                                  optional: true,
                                 is_string: false,
                             default_value: false),
          FastlaneCore::ConfigItem.new(key: :file,
                                  env_name: "XCCOV_FILE",
                               description: "Path to a specific file to view coverage for",
                                  optional: true,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :only_targets,
                                  env_name: "XCCOV_ONLY_TARGETS",
                               description: "Display only the targets from the report",
                                  optional: true,
                                 is_string: false,
                             default_value: false),
          FastlaneCore::ConfigItem.new(key: :files_for_target,
                                  env_name: "XCCOV_FILES_FOR_TARGET",
                               description: "Display the files for a specific target",
                                  optional: true,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :functions_for_file,
                                  env_name: "XCCOV_FUNCTIONS_FOR_FILE",
                               description: "Display the functions for a specific file",
                                  optional: true,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :json,
                                  env_name: "XCCOV_JSON",
                               description: "Output in JSON format",
                                  optional: true,
                                 is_string: false,
                             default_value: false),
          FastlaneCore::ConfigItem.new(key: :archive,
                                  env_name: "XCCOV_ARCHIVE",
                               description: "Treat .xcresult as an archive",
                                  optional: true,
                                 is_string: false,
                             default_value: false),
          FastlaneCore::ConfigItem.new(key: :report,
                                  env_name: "XCCOV_REPORT",
                               description: "Treat .xcresult as a report",
                                  optional: true,
                                 is_string: false,
                             default_value: false)
        ]
      end

      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
      end

      def self.example_code
        [
          'xccov_view(file_path: "coverage.xcresult", json: true)',
          'xccov_view(file_path: "coverage.xccovarchive", file_list: true)',
          'xccov_view(file_path: "coverage.xccovreport", only_targets: true)',
          'xccov_view(file_path: "coverage.xccovarchive", file: "MyApp/MyClass.swift")',
          'xccov_view(file_path: "coverage.xcresult", archive: true, json: true)',
          'xccov_view(file_path: "coverage.xcresult", report: true, files_for_target: "MyTarget")'
        ]
      end
    end
  end
end