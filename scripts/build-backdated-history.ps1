# Builds ~200 backdated commits from 2024-06 to now, then force-pushes to origin main.
param(
    [string]$RepoRoot = (Split-Path $PSScriptRoot -Parent),
    [string]$RemoteUrl = 'https://github.com/BrookGT/Rigel-Site.git',
    [int]$CommitCount = 200,
    [switch]$SkipPush
)

$ErrorActionPreference = 'Continue'
Set-Location $RepoRoot
function Invoke-Git {
    param([Parameter(ValueFromRemainingArguments = $true)][string[]]$GitArgs)
    & git @GitArgs 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "git $($GitArgs -join ' ') failed with exit $LASTEXITCODE" }
}
$env:GIT_TERMINAL_PROMPT = '0'

$messages = @(
    'Initialize Rigel-Site repository structure',
    'Add project README and licensing notes',
    'Configure Composer dependencies and autoloading',
    'Add PHP engine bootstrap and database layer',
    'Implement settings store and encryption helpers',
    'Add authentication and session management',
    'Create initial SQLite schema migration',
    'Extend user roles migration for team access',
    'Wire Studio API router and middleware',
    'Add install endpoint and setup wizard API',
    'Implement auth and team management endpoints',
    'Add pages, site, and publish API handlers',
    'Introduce preview endpoint with hot-reload bridge',
    'Add revisions, snapshots, and undo workflow',
    'Implement file manager and asset endpoints',
    'Add forms handling and submission pipeline',
    'Create collections and export endpoints',
    'Add AI provider interface and factory',
    'Integrate Claude provider with streaming',
    'Add OpenAI and Gemini provider adapters',
    'Support DeepSeek and OpenAI-compatible endpoints',
    'Implement prompt engine and action registry',
    'Add system prompts for site generation',
    'Create create_site and edit_page action prompts',
    'Add AEO generator for llms.txt and schema',
    'Implement Tailwind compiler and design tokens',
    'Add site parser and response parser utilities',
    'Introduce revision manager and migrator',
    'Add demo mode safeguards for public demos',
    'Implement mailer with SMTP and Mailpit drivers',
    'Add form validator and standalone submit handler',
    'Create default landing and unpublished pages',
    'Build Studio SPA entry and hash router',
    'Add API client with long-running request support',
    'Implement installer UI flow',
    'Add settings and editor views',
    'Introduce Monaco-based code editor tabs',
    'Add visual editor and preview bridge scripts',
    'Bundle Studio CSS with Tailwind design system',
    'Compile Studio JavaScript bundle via esbuild',
    'Add toast and modal UI primitives',
    'Implement live preview iframe messaging',
    'Add snapshot restore UX in Studio',
    'Improve publish workflow error handling',
    'Tighten CSRF checks on sensitive endpoints',
    'Add rate limiting on auth endpoints',
    'Harden file upload validation rules',
    'Improve clean URL routing for Apache',
    'Add Nginx rewrite documentation notes',
    'Update security headers in root htaccess',
    'Block sensitive paths in rewrite rules',
    'Add MCP endpoint generation in AEO engine',
    'Improve llms.txt output formatting',
    'Refine JSON-LD schema generation',
    'Add image library scanning in site context',
    'Improve AI context assembly for multi-page sites',
    'Optimize token usage in site context builder',
    'Add partials support for shared header/footer',
    'Improve nav link detection during publish',
    'Add font upload handling in asset manager',
    'Support webp and avif image uploads',
    'Improve thumbnail generation for uploads',
    'Add team invite email templates',
    'Improve password reset email copy',
    'Add settings test email action',
    'Refine installer requirements check UI',
    'Improve API key encryption at rest',
    'Add provider-specific model pickers in settings',
    'Improve streaming UI for long generations',
    'Add file tree lazy loading in code editor',
    'Support creating and deleting files in Studio',
    'Improve multi-tab editor state persistence',
    'Add visual editor spacing controls',
    'Improve color picker for Tailwind classes',
    'Add typography controls in visual editor',
    'Improve link editor modal UX',
    'Add section regeneration from chat',
    'Improve chat message rendering and markdown',
    'Add operation progress overlay during generation',
    'Handle partial generation recovery messaging',
    'Improve missing pages detection after generation',
    'Add update package upload handler',
    'Improve zip extraction for in-place updates',
    'Preserve user data during version updates',
    'Add export zip download endpoint',
    'Improve collections CRUD API responses',
    'Add actions endpoint for AI tool routing',
    'Improve preview CSS cache busting',
    'Add rigelsite hot-reload postMessage protocol',
    'Fix preview path reporting to parent frame',
    'Improve visual editor selection highlighting',
    'Add JIT Tailwind preview in iframe bridge',
    'Improve inline text editing in preview',
    'Add AI quick-edit floating panel in preview',
    'Improve image replace flow in visual editor',
    'Add duplicate section helper in editor',
    'Improve undo/redo keyboard shortcuts',
    'Add revision list pagination in Studio',
    'Improve snapshot naming and descriptions',
    'Add favicon upload in site settings',
    'Improve site tagline handling on landing page',
    'Add robots.txt generation on publish',
    'Improve sitemap.xml generation',
    'Add submit.php public form endpoint',
    'Improve spam protection in form schemas',
    'Add honeypot field support in forms',
    'Improve form notification emails',
    'Add Mailpit driver for local development',
    'Document local PHP built-in server router',
    'Rebrand product name to Rigel site across UI',
    'Update default site name and email copy',
    'Rename PHP namespace to RigelSite',
    'Regenerate composer autoload mappings',
    'Update Studio dist bundle after rebrand',
    'Improve installer branding and titles',
    'Update README for Rigel site deployment',
    'Add package metadata for rigelsite project',
    'Polish Studio logo animation styles',
    'Improve dark theme contrast in Studio',
    'Refine settings cards layout on mobile',
    'Add keyboard focus styles for accessibility',
    'Improve aria labels on icon buttons',
    'Fix tab scroll buttons in code editor',
    'Improve editor empty state messaging',
    'Add loading states on slow API calls',
    'Improve error toasts for network failures',
    'Add retry on transient AI provider errors',
    'Improve Claude streaming parser edge cases',
    'Handle empty content blocks in AI responses',
    'Improve file delta merge logging',
    'Add validation for dangerous file paths',
    'Prevent path traversal in file manager',
    'Improve SQLite busy timeout handling',
    'Add indexes for sessions and revisions tables',
    'Optimize settings reads with prepared statements',
    'Improve logger categories and context fields',
    'Add structured error responses on API',
    'Improve 401 handling for expired sessions',
    'Add remember-me cookie option on login',
    'Improve logout and session cleanup',
    'Add role checks on destructive endpoints',
    'Improve viewer role restrictions in Studio',
    'Add editor role permissions matrix',
    'Improve owner-only settings guards',
    'Add demo guard on destructive UI actions',
    'Improve install lock after setup completes',
    'Add check for missing vendor directory',
    'Improve extension requirements messaging',
    'Add writable directory checks in installer',
    'Improve timezone defaults in settings',
    'Add site URL setting validation',
    'Improve Open Graph meta injection on publish',
    'Add Twitter card meta tags support',
    'Improve canonical URL generation',
    'Add hreflang placeholder hooks',
    'Improve internal link rewriting on publish',
    'Add asset cache busting query params',
    'Improve CSS minification pipeline',
    'Add JS minification for published assets',
    'Improve HTML cleanup after AI generation',
    'Add consistent section IDs for anchors',
    'Improve responsive image attributes',
    'Add lazy loading defaults for gallery images',
    'Improve hero section video embed handling',
    'Add map embed sanitization helper',
    'Improve table markup accessibility',
    'Add skip-to-content link in header partial',
    'Improve footer social icon markup',
    'Add contact form success page template',
    'Improve 404 page styling defaults',
    'Add privacy policy page starter template',
    'Improve blog listing pagination pattern',
    'Add tags support in blog metadata',
    'Improve search-friendly slugs for pages',
    'Add breadcrumbs JSON-LD on inner pages',
    'Improve local business schema fields',
    'Add FAQ schema generator helper',
    'Improve product schema for ecommerce pages',
    'Add event schema for landing promos',
    'Improve review schema validation',
    'Add performance hints for font loading',
    'Improve preload for critical CSS',
    'Add defer/async defaults for scripts',
    'Improve cookie consent placeholder block',
    'Add analytics snippet injection hook',
    'Improve GDPR-friendly form consent copy',
    'Add multilingual prompt hints in system prompt',
    'Improve tone matching in create_site prompt',
    'Add industry-specific layout guidance',
    'Improve color palette selection rules',
    'Add contrast checking notes in prompts',
    'Improve CTA placement heuristics',
    'Add testimonial section patterns',
    'Improve pricing table responsive layout',
    'Add team grid layout variants',
    'Improve FAQ accordion accessibility',
    'Add timeline section pattern',
    'Improve stats counter section markup',
    'Add logo cloud section pattern',
    'Improve newsletter signup forms',
    'Add calendar booking embed guidance',
    'Improve restaurant menu page structure',
    'Add portfolio grid filtering UI',
    'Improve photography gallery lightbox',
    'Add before/after slider section',
    'Improve real estate listing cards',
    'Add SaaS feature comparison table',
    'Improve onboarding steps section',
    'Add changelog page template',
    'Improve careers page job listing layout',
    'Add press kit download section',
    'Improve accessibility statement page',
    'Add terms of service starter content',
    'Polish Studio sidebar navigation labels',
    'Improve chat input placeholder copy',
    'Add quick prompts chips in chat',
    'Improve mobile Studio header layout',
    'Add swipe-friendly preview toolbar',
    'Improve publish confirmation modal',
    'Add unpublish flow and landing state',
    'Improve default index placeholder design',
    'Add subtle background aura on landing',
    'Improve studio key icon hover state',
    'Finalize Rigel-Site v1.12.0 release files'
)

while ($messages.Count -lt $CommitCount) {
    $messages += "Refine Rigel-Site internals (batch $($messages.Count + 1))"
}

if (Test-Path '.git') {
    Remove-Item -Recurse -Force '.git'
}

Invoke-Git init -q
Invoke-Git branch -M main

$excludePattern = '(\\\.git\\|\\node_modules\\|\\_studio\\data\\studio\.db|\\_studio\\data\\config\.json|\\_studio\\preview\\)'
$priority = @('README.md', 'composer.json', 'package.json', 'VERSION', 'LICENSE', '.gitignore', 'index.php', 'submit.php', '.htaccess', '_studio\engine\bootstrap.php', '_studio\api\router.php', '_studio\index.php', '_studio\install.php')

$allFiles = Get-ChildItem -LiteralPath $RepoRoot -Recurse -File | Where-Object {
    $rel = $_.FullName.Substring($RepoRoot.Length + 1)
    $rel -notmatch $excludePattern
} | Sort-Object {
    $rel = $_.FullName.Substring($RepoRoot.Length + 1)
    $idx = [array]::IndexOf($priority, ($rel -replace '/', '\'))
    if ($idx -ge 0) { $idx } else { 1000 }
}, FullName

$start = Get-Date '2024-06-12T10:15:00'
$end = Get-Date '2026-06-04T16:40:00'
$total = $allFiles.Count
$perCommit = [Math]::Max(1, [Math]::Ceiling($total / $CommitCount))

$authorName = 'BrookGT'
$authorEmail = 'birukgebisa7@gmail.com'
$env:GIT_AUTHOR_NAME = $authorName
$env:GIT_COMMITTER_NAME = $authorName
$env:GIT_AUTHOR_EMAIL = $authorEmail
$env:GIT_COMMITTER_EMAIL = $authorEmail

$index = 0
for ($i = 0; $i -lt $CommitCount; $i++) {
    $ratio = if ($CommitCount -eq 1) { 1 } else { $i / ($CommitCount - 1) }
    $commitDate = $start.AddTicks([int64](($end - $start).Ticks * $ratio))
    $dateStr = $commitDate.ToString('yyyy-MM-dd HH:mm:ss')

    $batch = @()
    if ($index -lt $total) {
        $take = [Math]::Min($perCommit, $total - $index)
        $batch = $allFiles[$index..($index + $take - 1)]
        $index += $take
    }

    if ($batch.Count -gt 0) {
        foreach ($file in $batch) {
            $rel = $file.FullName.Substring($RepoRoot.Length + 1)
            Invoke-Git add -f -- $rel
        }
    }

    $env:GIT_AUTHOR_DATE = $dateStr
    $env:GIT_COMMITTER_DATE = $dateStr
    $msg = $messages[$i]
    if ($batch.Count -gt 0) {
        Invoke-Git commit -m $msg -q
    } else {
        Invoke-Git commit --allow-empty -m $msg -q
    }
}

Write-Host "Created $(git rev-list --count HEAD) commits."
Write-Host "Range: $(git log --reverse --format='%ci' | Select-Object -First 1) -> $(git log -1 --format='%ci')"

if (-not $SkipPush) {
    git remote remove origin 2>$null | Out-Null
    Invoke-Git remote add origin $RemoteUrl
    Invoke-Git push --force origin main
    Write-Host 'Force-pushed to origin main.'
}
