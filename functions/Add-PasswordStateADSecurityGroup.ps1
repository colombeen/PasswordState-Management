Function Add-PasswordStateADSecurityGroup
{
  [CmdletBinding(SupportsShouldProcess = $true,DefaultParameterSetName = 'UserID')]
  Param
  (
    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 0)][Alias('SecurityGroupName')][ValidateLength(1, 255)][string]$Name,
    [Parameter(ValueFromPipelineByPropertyName = $true, Position = 1)][ValidateLength(0, 255)][string]$Description,
    [Parameter(Position = 2)][string]$ADDomainNetBIOS = $env:USERDOMAIN,
    [Parameter(Position = 3)][switch]$PreventAuditing
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
      'SecurityGroupName' = $Name
      'ADDomainNetBIOS' = $ADDomainNetBIOS
    }
    
    If (!([string]::IsNullOrEmpty($Description)))
    {
      $Body | Add-Member -Name 'Description' -Value $Description -MemberType NoteProperty
    }
    
    If ($PSCmdlet.ShouldProcess("$($Name)"))
    {
      Try
      {
        New-PasswordStateResource -uri "/securitygroup/$($uri)" -body "$($Body | ConvertTo-Json)" -method POST
      }
      Catch
      {
        Throw $_.Exception
      }
    }
  }
}