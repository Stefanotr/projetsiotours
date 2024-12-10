# PowerShell Script to automate git add, commit, and push with a timestamped message
$dateTime = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
$commitMessage = "Maj PS-SCRIPT $dateTime"

# Change to the directory containing your git repository if necessary
# Set-Location -Path "C:\Users\Administrateur\Documents\GitHub\projetsiotours"

# Adding all changes to the staging area
git add .

# Committing changes with the timestamped message
git commit -m $commitMessage

# Pushing changes to the remote repository
git push
