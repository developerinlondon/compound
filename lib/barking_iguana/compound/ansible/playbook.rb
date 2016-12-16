module BarkingIguana
  module Compound
    module Ansible
      class Playbook
        attr_accessor :file, :inventory_path, :limit_pattern, :run_from, :user_name, :private_key_file, :io, :output_verbosity, :show_diff

        def initialize file, run_from: nil
          self.file = file
          self.run_from = run_from
          self.output_verbosity = 0
          self.show_diff = false
        end

        def verbosity n
          self.output_verbosity = n.to_i
          self
        end

        def diff
          self.show_diff = !self.show_diff
          self
        end

        def stream_to io
          self.io = io
          self
        end

        def inventory name
          self.inventory_path = name
          self
        end

        def user name
          self.user_name = name
          self
        end

        def private_key key_file
          self.private_key_file = key_file
          self
        end

        def limit pattern
          self.limit_pattern = pattern
          self
        end

        def run
          options = {}
          options[:cwd] = run_from if run_from
          options[:live_stream] = io if io
          c = Mixlib::ShellOut.new(command, options)
          c.run_command
          c.error!
          self
        ensure
          clean_up
        end

        private

        def clean_up
          return unless run_from
          FileUtils.remove_file wrapper_playbook, true
        end

        # TODO: Symlink the playbook to wrapper_playbook.path
        # so we can use the group_vars, host_vars, etc.
        def playbook_path
          return file unless run_from
          tempfile = wrapper_playbook
          FileUtils.symlink file, tempfile
          tempfile
        end

        def wrapper_playbook_content
          "---\n- include: #{file}"
        end

        def wrapper_playbook
          @wrapper_playbook ||= begin
            name = [
              'playbook',
              Process.pid,
              Time.now.to_i,
              rand(9_999_999_999).to_s.rjust(10, '0')
            ].join('-') + '.yml'
            File.expand_path(name, run_from)
          end
        end

        def command
          c = "env ANSIBLE_RETRY_FILES_ENABLED=no ansible-playbook #{playbook_path} -i #{inventory_path}"
          c << " -l #{limit_pattern}," unless limit_pattern.nil?
          c << " -u #{user_name}" unless user_name.nil?
          c << " -#{'v' * output_verbosity}" if output_verbosity > 0
          c << " --diff" if show_diff
          c << " --private-key=#{private_key_file}" unless private_key_file.nil?
          c
        end
      end
    end
  end
end