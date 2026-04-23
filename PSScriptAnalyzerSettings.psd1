@{
    # Configuration PSScriptAnalyzer pour Lucky Terminal
    # Doc : https://learn.microsoft.com/fr-fr/powershell/utility-modules/psscriptanalyzer/using-scriptanalyzer
    #
    # NB : le fichier évite l'alignement visuel multi-espaces pour rester
    # compatible avec PSUseConsistentWhitespace (CheckOperator = $true).

    Severity = @('Error', 'Warning')
    IncludeDefaultRules = $true

    ExcludeRules = @(
        # Write-Host est un choix délibéré pour la communication avec l'utilisateur
        # (messages d'installation colorés). Pas applicable à un script d'installeur.
        'PSAvoidUsingWriteHost',

        # Les scripts d'install/désinstall sont interactifs (-Yes/-h), pas des cmdlets
        # réutilisables ; ajouter -WhatIf/-Confirm partout complexifierait sans valeur.
        'PSUseShouldProcessForStateChangingFunctions',

        # Le projet utilise quelques verbes non approuvés pour la lisibilité
        # (Ensure-Dir, Refresh-UserPath, Confirm-Step). À revoir dans un chantier
        # de renommage ultérieur si on veut resserrer.
        'PSUseApprovedVerbs',

        # Invoke-Expression est nécessaire pour `oh-my-posh init` (pattern officiel
        # documenté sur ohmyposh.dev). Le risque est maîtrisé car la source est fixe.
        'PSAvoidUsingInvokeExpression',

        # BOM UTF-8 non requis sur pwsh 7+ cross-platform. Nos fichiers sont UTF-8
        # sans BOM (LF/CRLF géré via .gitattributes).
        'PSUseBOMForUnicodeEncodedFile'
    )

    Rules = @{
        PSPlaceOpenBrace = @{
            Enable = $true
            OnSameLine = $true
            NewLineAfter = $true
            IgnoreOneLineBlock = $true
        }

        PSPlaceCloseBrace = @{
            Enable = $true
            NewLineAfter = $false
            IgnoreOneLineBlock = $true
            NoEmptyLineBefore = $false
        }

        PSUseConsistentIndentation = @{
            Enable = $true
            IndentationSize = 4
            Kind = 'space'
        }

        PSUseConsistentWhitespace = @{
            Enable = $true
            CheckOpenBrace = $true
            CheckOpenParen = $true
            CheckOperator = $true
            CheckSeparator = $true
        }

        # Désactivé : PSAlignAssignmentStatement crée des conflits avec
        # PSUseConsistentWhitespace (plusieurs espaces avant `=` vs un seul).
        # On préfère le single-space partout pour la cohérence.
        PSAlignAssignmentStatement = @{
            Enable = $false
        }
    }
}
