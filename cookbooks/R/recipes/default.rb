execute "install_r" do
  command "emerge dev-lang/R"
  not_if { FileTest.exists?("/usr/lib/R") }
end
