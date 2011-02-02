def section_exists?(file, section, opts={})
  failable_shell("grep '# #{section}:' '#{file}'", opts).result
end

def append_to_file_with_section(text, file, section, opts={})
  unless section_exists?(file, section, opts)
    shell("cat >> #{file}", opts.merge(:input => "# #{section}: #{added_by_babushka(text.split("\n").length + 1)}\n#{text}\n# #{section}:end\n"))
  end
end

def remove_babushka_section(file, section, opts={})
  delimiter = failable_shell("grep '# #{section}:' '#{file}'", opts).stdout
  unless delimiter.empty?
    text = shell("cat #{file}", opts)
    shell("cat > #{file}", opts.merge(:input => text.gsub(/# #{section}:.*# #{section}:end/im, '')))
  end
end