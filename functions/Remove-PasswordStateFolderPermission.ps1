Function Remove-PasswordStateFolderPermission
{
  [CmdletBinding(SupportsShouldProcess = $true,DefaultParameterSetName = 'UserID')]
  Param
  (
    [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 0)][ValidateNotNullOrEmpty()][int32]$FolderID,
    [Parameter(ValueFromPipelineByPropertyName = $true, Position = 1, HelpMessage = 'A for Administrator, M for Modify or V for View permissions')][ValidateSet('A', 'M', 'V')][string]$Permission,
    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 2, ParameterSetName = 'UserID')][Alias('ApplyPermissionsForUserID')][ValidateLength(1,100)][string]$UserID,
    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 2, ParameterSetName = 'SecurityGroupID')][Alias('ApplyPermissionsForSecurityGroupID')][ValidateNotNullOrEmpty()][int32]$SecurityGroupID,
    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 2, ParameterSetName = 'SecurityGroupName')][Alias('ApplyPermissionsForSecurityGroupName')][ValidateNotNullOrEmpty()][string]$SecurityGroupName,
    [Parameter(ValueFromPipelineByPropertyName, Position = 3)][switch]$PreventAuditing
  )
  
  Process
  {
    $uri = ''
    If ($PreventAuditing.IsPresent)
    {
      $uri = '?PreventAuditing=true'
    }
    
    # Create the post object
    $Body = [PSCustomObject] @{
      'FolderID' = $FolderID
    }
    
    If (!([string]::IsNullOrEmpty($Permission)))
    {
      $Body | Add-Member -Name 'Permission' -Value $Permission -MemberType NoteProperty
    }
    
    Switch ($PSCmdlet.ParameterSetName)
    {
      'UserID' {
        $Body | Add-Member -Name 'ApplyPermissionsForUserID' -Value $UserID -MemberType NoteProperty
      }
      'SecurityGroupID' {
        $Body | Add-Member -Name 'ApplyPermissionsForSecurityGroupID' -Value $SecurityGroupID -MemberType NoteProperty
      }
      'SecurityGroupName' {
        $Body | Add-Member -Name 'ApplyPermissionsForSecurityGroupName' -Value $SecurityGroupName -MemberType NoteProperty
      }
    }
    
    If ($PSCmdlet.ShouldProcess("FolderID $($FolderID)"))
    {
      Try
      {
        Set-PasswordStateResource -uri "/folderpermissions/$($uri)" -body "$($Body | ConvertTo-Json)" -method DELETE
      }
      Catch
      {
        Throw $_.Exception
      }
    }
  }
}