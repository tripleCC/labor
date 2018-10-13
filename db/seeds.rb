require_relative '../lib/labor/models/main_deploy'

100.times.each do |i|	
	Labor::MainDeploy.create(
		name: '发布' + i.to_s, 
		repo_url: 'git@git.2dfire-inc.com:qingmu/PodD.git', 
		ref: 'release/0.2.2'
	)
end
