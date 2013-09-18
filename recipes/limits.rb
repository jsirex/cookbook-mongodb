# Applying custom limits settings to mongods' user

ulimit_domain 'mongodb' do
  [:hard, :soft].each do |limit_type|
    rule do
      item :fsize
      type limit_type
      value 'unlimited'
    end
    rule do
      item :cpu
      type limit_type
      value 'unlimited'
    end
    rule do
      item :nofile
      type limit_type
      value 64000
    end
    rule do
      item :nproc
      type limit_type
      value 32000
    end
  end
end
