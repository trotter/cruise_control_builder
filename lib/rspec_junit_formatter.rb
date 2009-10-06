require 'spec/runner/formatter/base_text_formatter'

# A JUnit formatter for rspec output. Run with
# script/spec --require lib/rspec_junit_formatter.rb --format JUnitFormatter *specs
class JUnitFormatter < Spec::Runner::Formatter::BaseTextFormatter 
  attr_accessor :example_group_number

  def initialize(options, output)
    super
    @example_group_number = 0
  end

  def start(example_count)
    @output.puts "<testsuites>"
  end

  def example_group_started(example_group)
    super
    self.example_group_number += 1
    unless example_group_number == 1
      @output.puts %Q[  </testsuite>]
    end
    @output.puts %Q[  <testsuite name="#{example_group.description}" package="test">]
  end

  def dump_summary(duration, example_count, failure_count, pending_count)
    @output.puts "  </testsuite>" if example_group_number > 0
    @output.puts "</testsuites>"
  end

  def example_passed(example)
    @output.puts common_example_output(example) + "/>"
  end

  def example_failed(example, counter, failure)
    @output.puts common_example_output(example) + ">"
    @output.puts %Q[      <failure message="#{failure.exception.message}">]
    @output.puts failure.exception.backtrace
    @output.puts %Q[      </failure>]  
    @output.puts %Q[    </testcase>]
  end

  def dump_failure(counter,failure)
    @output.puts "dumping failure"
    # ... do nothing ...
  end

  def dump_pending
    # ... do nothing ...
  end

  private
    def common_example_output(example)
      name = example.description.gsub(/\s/, "_").gsub(/[^A-Za-z0-9\-_]/, '')
      classname = "test.#{@example_group.description.gsub(/\s/, "_").gsub(/[^A-Za-z0-9\-_]/, '')}"
      %Q[    <testcase name="#{name}" classname="#{classname}"]
    end
end

