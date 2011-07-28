# Manually for right now
# launch two servers: instance1, instance2
# Find the two instances' resource_uids --- manually
# Attach two volumes to server1

# Manual Commands to shell:
# client
# Manual Commands to irb:
# load "~/work/right_api_client/examples/backups_tests.rb"


# NOTE: will retore to instance2
# NOTE: for right now it is default to cloud 907

# inputs into the script:

# |||||||||||||| CHANGE HERE ||||||||||||||
# For right now manually add these resource_uids of the two servers that you launched.
resource_uid_1 = "i-999f75de"
resource_uid_2 = "i-939f75d4"
# ||||||||||||||||||||||||||||||||||||||||||||

# Get the necessary information. Must have @client pointing to where you want it
@test_client = @moo
@instance1_id = @test_client.clouds(:id => 907).show.instances.index(:filter => ["resource_uid==#{resource_uid_1}"]).first.show.href.split("/")[-1]
@instance2_id = @test_client.clouds(:id => 907).show.instances.index(:filter => ["resource_uid==#{resource_uid_2}"]).first.show.href.split("/")[-1]


@volume_attachment_href_1 = @test_client.clouds(:id => 907).show.instances(:id => @instance1_id).show.volume_attachments.index[0].show.href

@volume_attachment_href_2 = @test_client.clouds(:id => 907).show.instances(:id => @instance1_id).show.volume_attachments.index[1].show.href

# |||||||||||||| CHANGE HERE if you want to test the instance facing calls||||||||||||||
#@test_client = @instance_client
# ||||||||||||||||||||||||||||||||||||||||||||

def create(name)
  p "Doing a create ..."
  params = {:backup => {:lineage => "ns_backup_test_lineage", :name => name, :volume_attachment_hrefs => [@volume_attachment_href_1, @volume_attachment_href_2]}}
  return @test_client.backups.create(params)
end

def index
  p "Doing an index ..."
  return @test_client.backups.index(:lineage => "ns_backup_test_lineage")
end


def show
  p "Doing a show on the first backup ..."
  backup = @test_client.backups.index(:lineage => "ns_backup_test_lineage").first
  if backup
    id = backup.show.href.split("/")[-1]   # => to get the id
    resource = @test_client.backups(:id => id)
    p "The api methods are: #{resource.show.api_methods}"
    p "The volume snapshots are: #{resource.show.volume_snapshots}"
    return @test_client.backups(:id => id)
  else
    p "there are no backups: #{@test_client.backups(:lineage => "ns_backup_test_lineage")}"
  end
end

def update
  p "Doing an update on ALL backups ..."
  for backup in @test_client.backups.index(:lineage => "ns_backup_test_lineage")
    id = backup.show.href.split("/")[-1]   # => to get the id
    resource = @test_client.backups(:id => id)
    p "The committed for right now is: #{resource.show.committed}"
    params = {:backup => {:committed => "true"}}
    p "Updating it."
    resource.update(params)
    resource = @test_client.backups(:id => id)
    p "The committed now is: #{resource.show.committed}"
  end
end
  
def cleanup
  # Note committed need to be true
  #p "Doing another create so that we can see cleanup in action ..."
  #create("Ns Backup Test 500")
  #p "Doing an update so that all the committed are true ...."
  #update
  p "Doing an index before the cleanup ...."
  p index
  p "Doing a cleanup ..."
  params = {:keep_last => "1", :lineage => "ns_backup_test_lineage"}
  result = @test_client.backups.cleanup(params)
  p result
  p "Doing an index after the cleanup ...."
  p index
end


# Restore: 
#   If using instance facing calls: need to restore to the instance that you are currently logged in as: therefore, this one cannot have the volumes attached
#   If you are using normal login: restore to the one that does not have the volumes attached

def restore
  p "Doing a restore ..."
  params = {:instance_href => "/api/clouds/907/instances/#{@instance2_id}"}
  id = @test_client.backups.index(:lineage => "ns_backup_test_lineage").first.show.href.split("/")[-1]   # => to get the id
  task = @test_client.backups(:id => id).show.restore(params)
  return task
end



def destroy
  p "Doing a destroy ..."
  id = @test_client.backups.index(:lineage => "ns_backup_test_lineage").first.show.href.split("/")[-1]   # => to get the id
  @test_client.backups(:id => id).destroy
end


def follow_task(task)
  task_id = task.show.href.split("/")[-1]
  p "The summary so far is: #{@test_client.clouds(:id => 907).show.instances(:id => @instance2_id).show.live_tasks(:id => task_id).show.summary}"
  p "Querry this again to get an even more updated summary!"
end

def change_client(new_client)
  @test_client = new_client
end



















