# xccov plugin

[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-xccov)

## Getting Started

This project is a [_fastlane_](https://github.com/fastlane/fastlane) plugin. To get started with `fastlane-plugin-xccov`, add it to your project by running:

```bash
fastlane add_plugin xccov
```

## About xccov

A fastlane plugin that provides integration with Apple's `xccov` command-line tool for code coverage analysis. This plugin allows you to easily view, compare, and merge code coverage reports from your iOS and macOS test runs directly in your fastlane workflows.

The plugin supports all major xccov commands:
- **view**: Examine code coverage data from .xccovarchive, .xccovreport, or .xcresult files
- **diff**: Compare code coverage between two reports
- **merge**: Combine multiple coverage reports into a single report

## Actions

### xccov_view

View code coverage data from .xccovarchive, .xccovreport, or .xcresult files.

```ruby
# View code coverage data from an xcresult bundle
xccov_view(
  file_path: "test_result.xcresult",
  json: true
)

# View files for a specific target
xccov_view(
  file_path: "test_result.xcresult",
  report: true,
  files_for_target: "MyAppTarget",
  json: true
)

# View only the targets from a coverage report
xccov_view(
  file_path: "coverage.xccovreport",
  only_targets: true
)

# List files in an xccovarchive
xccov_view(
  file_path: "coverage.xccovarchive",
  file_list: true
)

# View coverage for a specific file
xccov_view(
  file_path: "coverage.xccovarchive",
  file: "MyApp/MyClass.swift"
)

# View functions for a specific file
xccov_view(
  file_path: "coverage.xccovreport",
  functions_for_file: "MyApp/MyClass.swift"
)
```

### xccov_diff

Compare code coverage between two .xccovreport or .xcresult files.

```ruby
# Compare coverage between two xccovreport files
xccov_diff(
  before_path: "before.xccovreport",
  after_path: "after.xccovreport",
  json: true
)

# Compare coverage between two xcresult bundles
xccov_diff(
  before_path: "before.xcresult",
  after_path: "after.xcresult",
  json: true
)

# Compare coverage with path equivalence for files that moved 
xccov_diff(
  before_path: "before.xcresult",
  after_path: "after.xcresult",
  path_equivalence: "/OldPath,/NewPath",
  json: true
)
```

### xccov_merge

Merge multiple .xccovreport and (optionally) .xccovarchive files into a single coverage report.

```ruby
# Merge multiple xccovreport files
xccov_merge(
  reports: ["report1.xccovreport", "report2.xccovreport"],
  out_report: "merged.xccovreport"
)

# Merge multiple xccovreport files with their corresponding archives
xccov_merge(
  reports: ["report1.xccovreport", "report2.xccovreport"],
  archives: ["archive1.xccovarchive", "archive2.xccovarchive"],
  out_report: "merged.xccovreport",
  out_archive: "merged.xccovarchive"
)
```

### Wrapper Action

You can also use the main `xccov` action as a wrapper that delegates to the specific command actions:

```ruby
# Using the wrapper action for view
xccov(
  command: :view,
  file_path: "coverage.xcresult",
  json: true
)

# Using the wrapper action for diff
xccov(
  command: :diff,
  before_path: "before.xcresult",
  after_path: "after.xcresult",
  json: true
)

# Using the wrapper action for merge
xccov(
  command: :merge,
  reports: ["report1.xccovreport", "report2.xccovreport"],
  out_report: "merged.xccovreport"
)
```

## Example Fastfile

Here's an example of how you might integrate xccov into your fastlane workflow:

```ruby
lane :analyze_coverage do
  # Run tests and generate coverage report
  scan(
    scheme: "MyApp",
    code_coverage: true,
    derived_data_path: "./DerivedData",
    result_bundle: true
  )
  
  # Get the path to the latest test result
  xcresult_path = Dir["./DerivedData/Logs/Test/Run-*.xcresult"].sort_by { |f| File.mtime(f) }.last
  
  # View coverage summary
  coverage_data = xccov_view(
    file_path: xcresult_path,
    report: true,
    only_targets: true,
    json: true
  )
  
  # Parse the coverage data and fail if below threshold
  total_coverage = coverage_data.first["lineCoverage"]
  UI.message "Total coverage: #{(total_coverage * 100).round(2)}%"
  
  if total_coverage < 0.7  # 70% threshold
    UI.user_error!("Code coverage is below the required threshold of 70%")
  end
end
```

## Run tests for this plugin

To run both the tests, and code style validation, run

```
rake
```

To automatically fix many of the styling issues, use
```
rubocop -a
```

## Issues and Feedback

For any other issues and feedback about this plugin, please submit it to this repository.

## Troubleshooting

If you have trouble using plugins, check out the [Plugins Troubleshooting](https://docs.fastlane.tools/plugins/plugins-troubleshooting/) guide.

## Using _fastlane_ Plugins

For more information about how the `fastlane` plugin system works, check out the [Plugins documentation](https://docs.fastlane.tools/plugins/create-plugin/).

## About _fastlane_

_fastlane_ is the easiest way to automate beta deployments and releases for your iOS and Android apps. To learn more, check out [fastlane.tools](https://fastlane.tools).
