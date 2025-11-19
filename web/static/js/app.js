// Sandman Web UI - JavaScript

let mappedFolderCount = 0;

// Tab switching
document.querySelectorAll('.tab-btn').forEach(btn => {
    btn.addEventListener('click', () => {
        const tabName = btn.dataset.tab;

        // Update buttons
        document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');

        // Update content
        document.querySelectorAll('.tab-content').forEach(content => content.classList.remove('active'));
        document.getElementById(`${tabName}-tab`).classList.add('active');

        // Load data if needed
        if (tabName === 'configs') {
            loadConfigs();
        } else if (tabName === 'templates') {
            loadTemplates();
        }
    });
});

// Show notification
function showNotification(message, type = 'info') {
    const notification = document.getElementById('notification');
    notification.textContent = message;
    notification.className = `notification ${type} show`;

    setTimeout(() => {
        notification.classList.remove('show');
    }, 3000);
}

// Load configurations
async function loadConfigs() {
    try {
        const response = await fetch('/api/configs');
        const data = await response.json();

        const container = document.getElementById('configs-list');

        if (!data.success || data.files.length === 0) {
            container.innerHTML = `
                <div class="empty-state">
                    <h3>No configurations yet</h3>
                    <p>Create your first sandbox configuration to get started!</p>
                    <button class="btn btn-primary" onclick="document.querySelector('[data-tab=create]').click()">
                        ✨ Create New Configuration
                    </button>
                </div>
            `;
            return;
        }

        container.innerHTML = data.files.map(file => `
            <div class="config-card">
                <h3>📋 ${file.name}</h3>
                <div class="meta">📅 Modified: ${new Date(file.modified).toLocaleString()}</div>
                <div class="meta">📊 Size: ${formatBytes(file.size)}</div>
                <div class="actions">
                    <button class="btn btn-primary btn-small" onclick="viewConfig('${file.name}')">👁️ View</button>
                    <button class="btn btn-success btn-small" onclick="downloadConfig('${file.name}')">⬇️ Download</button>
                    <button class="btn btn-danger btn-small" onclick="deleteConfig('${file.name}')">🗑️ Delete</button>
                </div>
            </div>
        `).join('');
    } catch (error) {
        showNotification('Failed to load configurations: ' + error.message, 'error');
    }
}

// View configuration
async function viewConfig(name) {
    try {
        const response = await fetch(`/api/config/${name}`);
        const data = await response.json();

        if (!data.success) {
            showNotification('Failed to load configuration: ' + data.error, 'error');
            return;
        }

        const config = data.config;
        const details = `
            <strong>Configuration: ${name}</strong><br><br>
            💾 Memory: ${config.memory_mb} MB<br>
            🌐 Networking: ${config.networking}<br>
            🎮 vGPU: ${config.vgpu}<br>
            🔐 Protected Mode: ${config.protected_client}<br>
            📋 Clipboard: ${config.clipboard_redirection}<br>
            🖨️ Printer: ${config.printer_redirection}<br>
            🎤 Audio Input: ${config.audio_input}<br>
            📹 Video Input: ${config.video_input}<br>
            ${config.mapped_folders.length > 0 ? '<br><strong>Mapped Folders:</strong><br>' + config.mapped_folders.map(f => `📁 ${f.path} (${f.readonly ? 'Read-Only' : 'Read-Write'})`).join('<br>') : ''}
        `;

        if (confirm(details + '\n\nWould you like to download this configuration?')) {
            downloadConfig(name);
        }
    } catch (error) {
        showNotification('Failed to view configuration: ' + error.message, 'error');
    }
}

// Download configuration
async function downloadConfig(name) {
    try {
        window.location.href = `/api/config/${name}/download`;
        showNotification('Downloading configuration...', 'success');
    } catch (error) {
        showNotification('Failed to download: ' + error.message, 'error');
    }
}

// Delete configuration
async function deleteConfig(name) {
    if (!confirm(`Are you sure you want to delete "${name}"?`)) {
        return;
    }

    try {
        const response = await fetch(`/api/config/${name}`, {
            method: 'DELETE'
        });
        const data = await response.json();

        if (data.success) {
            showNotification(data.message, 'success');
            loadConfigs();
        } else {
            showNotification('Failed to delete: ' + data.error, 'error');
        }
    } catch (error) {
        showNotification('Failed to delete: ' + error.message, 'error');
    }
}

// Refresh configurations
function refreshConfigs() {
    showNotification('Refreshing...', 'info');
    loadConfigs();
}

// Create configuration form
document.getElementById('create-form').addEventListener('submit', async (e) => {
    e.preventDefault();

    const formData = new FormData(e.target);
    const data = {
        name: formData.get('name'),
        memory_mb: parseInt(formData.get('memory_mb')),
        networking: formData.get('networking'),
        vgpu: formData.get('vgpu'),
        audio_input: formData.get('audio_input'),
        video_input: formData.get('video_input'),
        clipboard_redirection: formData.get('clipboard_redirection'),
        printer_redirection: formData.get('printer_redirection'),
        protected_client: formData.get('protected_client'),
        mapped_folders: []
    };

    // Collect mapped folders
    document.querySelectorAll('.mapped-folder').forEach(folderDiv => {
        const path = folderDiv.querySelector('input[type="text"]').value.trim();
        const readonly = folderDiv.querySelector('input[type="checkbox"]').checked;

        if (path) {
            data.mapped_folders.push({ path, readonly });
        }
    });

    try {
        const response = await fetch('/api/config', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(data)
        });

        const result = await response.json();

        if (result.success) {
            showNotification(result.message, 'success');
            e.target.reset();
            mappedFolderCount = 0;
            document.getElementById('mapped-folders-container').innerHTML = '';

            // Switch to configs tab
            setTimeout(() => {
                document.querySelector('[data-tab="configs"]').click();
            }, 1500);
        } else {
            showNotification('Failed to create: ' + result.error, 'error');
        }
    } catch (error) {
        showNotification('Failed to create: ' + error.message, 'error');
    }
});

// Add mapped folder
function addMappedFolder() {
    mappedFolderCount++;
    const container = document.getElementById('mapped-folders-container');

    const folderDiv = document.createElement('div');
    folderDiv.className = 'mapped-folder';
    folderDiv.innerHTML = `
        <input type="text" placeholder="C:\\path\\to\\folder" />
        <label>
            <input type="checkbox" checked />
            Read-Only
        </label>
        <button type="button" class="btn btn-danger btn-small" onclick="this.parentElement.remove()">❌</button>
    `;

    container.appendChild(folderDiv);
}

// Load templates
async function loadTemplates() {
    try {
        const response = await fetch('/api/templates');
        const data = await response.json();

        const container = document.getElementById('templates-list');

        if (!data.success || data.templates.length === 0) {
            container.innerHTML = `
                <div class="empty-state">
                    <h3>No templates found</h3>
                    <p>Templates should be in the templates/ directory</p>
                </div>
            `;
            return;
        }

        const icons = {
            'minimal': '🚀',
            'secure': '🔒',
            'development': '💻',
            'full': '🌟',
            'default': '📦'
        };

        container.innerHTML = data.templates.map(template => {
            const icon = icons[template.name.toLowerCase()] || icons.default;
            return `
                <div class="template-card">
                    <h3>${icon} ${template.name}</h3>
                    <button class="btn btn-secondary" onclick="applyTemplate('${template.name}')">
                        ✨ Use Template
                    </button>
                </div>
            `;
        }).join('');
    } catch (error) {
        showNotification('Failed to load templates: ' + error.message, 'error');
    }
}

// Apply template
async function applyTemplate(templateName) {
    const newName = prompt(`Enter name for new configuration based on "${templateName}":`);

    if (!newName || !newName.trim()) {
        return;
    }

    try {
        const response = await fetch(`/api/template/${templateName}/apply`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ new_name: newName.trim() })
        });

        const data = await response.json();

        if (data.success) {
            showNotification(data.message, 'success');
            document.querySelector('[data-tab="configs"]').click();
        } else {
            showNotification('Failed to apply template: ' + data.error, 'error');
        }
    } catch (error) {
        showNotification('Failed to apply template: ' + error.message, 'error');
    }
}

// Format bytes
function formatBytes(bytes) {
    if (bytes < 1024) return bytes + ' B';
    if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + ' KB';
    return (bytes / (1024 * 1024)).toFixed(1) + ' MB';
}

// Initialize
document.addEventListener('DOMContentLoaded', () => {
    loadConfigs();
});
