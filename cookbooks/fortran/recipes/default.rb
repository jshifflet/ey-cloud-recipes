execute "install_fortran" do
  command "USE='fortran' emerge =sys-devel/gcc-4*"
  not_if { FileTest.exists?("/usr/bin/gfortran")}
end
