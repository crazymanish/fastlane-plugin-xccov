require 'fastlane/action'
require_relative '../helper/xccov_helper'

module Fastlane
  module Actions
    class XccovDiffAction < Action
      def self.run(params)
        cmd = ["xcrun", "xccov", "diff"]
        
        # Add json flag if requested
        cmd << "--json" if params[:json]
        
        # Add path equivalence if provided
        if params[:path_equivalence]
          from, to = params[:path_equivalence].split(",")
          cmd << "--path-equivalence" << "#{from},#{to}"
        end
        
        # Add before and after paths
        cmd << params[:before_path]
        cmd << params[:after_path]
        
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
        "Compare code coverage data using Apple's xccov diff command"
      end

      def self.authors
        ["crazymanish"]
      end

      def self.return_value
        "Returns the output of the xccov diff command (string or parsed JSON)"
      end

      def self.details
        "This action allows you to compare code coverage between two .xccovreport or .xcresult files"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :before_path,
                                  env_name: "XCCOV_DIFF_BEFORE_PATH",
                               description: "Path to the 'before' coverage file (.xccovreport or .xcresult)",
                                  optional: false,
                                      type: String,
                              verify_block: proc do |value|
                                              UI.user_error!("File does not exist at path '#{value}'") unless File.exist?(value)
                                            end),
          FastlaneCore::ConfigItem.new(key: :after_path,
                                  env_name: "XCCOV_DIFF_AFTER_PATH",
                               description: "Path to the 'after' coverage file (.xccovreport or .xcresult)",
                                  optional: false,
                                      type: String,
                              verify_block: proc do |value|
                                              UI.user_error!("File does not exist at path '#{value}'") unless File.exist?(value)
                                            end),
          FastlaneCore::ConfigItem.new(key: :json,
                                  env_name: "XCCOV_DIFF_JSON",
                               description: "Output in JSON format",
                                  optional: true,
                                 is_string: false,
                             default_value: false),
          FastlaneCore::ConfigItem.new(key: :path_equivalence,
                                  env_name: "XCCOV_DIFF_PATH_EQUIVALENCE",
                               description: "Path equivalence for different file paths in comma-separated format 'from,to'",
                                  optional: true,
                                      type: String)
        ]
      end

      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
      end

      def self.example_code
        [
          'xccov_diff(before_path: "before.xccovreport", after_path: "after.xccovreport", json: true)',
          'xccov_diff(before_path: "before.xcresult", after_path: "after.xcresult", json: true, path_equivalence: "/OldPath,/NewPath")'
        ]
      end
    end
  end
end