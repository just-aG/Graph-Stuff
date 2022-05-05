#Connect to Graph
$appID = "" #<- App ID from application registration in Azure AD
$tenantID = "" #<- Tenant ID from application registration in Azure AD
$certThumb = "" #<- Certificate thumbprint from application registration in Azure AD

#Uses PS SDK - Automatically Refreshes Token until disconnect-MGGraph is run
Connect-MgGraph -ClientId $appID -TenantId $tenantID -CertificateThumbprint $certThumb

Function SetEvent
{
    Param(
        [Parameter(Mandatory = $true,
            Position = 0)]
        [ValidateNotNullOrEmpty()]
        [String]$User
    )
    #batch URI
    $queryURI = "https://graph.microsoft.com/v1.0/`$batch"

    $bodyCreation = @{
        "requests" = @(
            @{
                "id"      = "1";
                "method"  = "POST";
                "url"     = "/users/$User/calendar/events";
                "body"    = @{
                    "subject"  = "Cinco De Mayo"; #Add Subject of Event
                    "body"     = @{
                        "contentType" = "HTML";
                        "content"     = "May 5th" #Add body content
                    };
                    "start"    = @{
                        "dateTime" = "2022-05-05T00:00:00"; #Add start dateTime
                        "timeZone" = "America/Denver" #Add TimeZone
                    };
                    "end"      = @{
                        "dateTime" = "2022-05-05T00:00:00"; #Add end dateTime
                        "timeZone" = "America/Denver" #Add TimeZone
                    };
                    "isAllDay" = $false #All day? T/F
                };
                "headers" = @{
                    "Content-Type" = "application/json"
                }
            };          
        )
    }

    $body = $bodyCreation | ConvertTo-Json -Depth 4

    #Uses SDK session token to submit request
    $A=Invoke-MgGraphRequest -Body $body -Uri $queryURI -Method "POST"
    $B=$A.responses.status
    Return $B
}

#Run Get-MgGroup to get list of Groups in environment - grab GroupID 
$users = Get-MgGroupMember -GroupId  # <- Update this to the desired group.

#Create Appointments
$users | ForEach-Object{
    SetEvent -User $_.Id
}