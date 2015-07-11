exports.cliVersion = '>=3.4.2';
exports.id = "ti.notificare.hook";
exports.version = "1.0";

exports.init = function (logger, config, cli, appc) {

	cli.on('build.android.writeAndroidManifest', {
		pre: function(data, next) {
			if (data.args[1] && data.args[1].application && data.args[1].application.activity && data.ctx && data.ctx.classname) {
				var parentActivityName = '.' + data.ctx.classname + 'Activity';
				var activity = data.args[1].application.activity['re.notifica.ui.NotificationActivity'];
				if (activity && activity.parentActivityName) {
					activity.parentActivityName = parentActivityName;
					if (activity['meta-data'] && activity['meta-data']['android.support.PARENT_ACTIVITY']) {
						activity['meta-data']['android.support.PARENT_ACTIVITY'].value = parentActivityName;						
					}
				}
			}
			next(null, data);
	}});
	cli.on('build.android.aapt', {
		pre: function(data, next) {
			var args = data.args[1];
			if (args.indexOf('--auto-add-overlay') < 0) {
				args.push('--auto-add-overlay');
	        }
			var externalLibraries = [{
					javaClass: 'com.google.android.gms',
					resPath: config.android.sdkPath + '/extras/google/google_play_services/libproject/google-play-services_lib/res'
			}];
	
			// --extra-packages can be defined just once
			if (args.indexOf('--extra-packages') < 0) {
				args.push('--extra-packages');
				args.push('');
			}
			var namespaceIndex = args.indexOf('--extra-packages') + 1;
			
			externalLibraries.forEach(function(lib) {
				if (args[namespaceIndex].indexOf(lib.javaClass) < 0) {
					args[namespaceIndex].length && (args[namespaceIndex] += ':');
					args[namespaceIndex] += lib.javaClass;
				}
				if (args.indexOf(lib.resPath) < 0) {
					args.push('-S');
					args.push(lib.resPath);
				}
			});
			next(null, data);
		}
	});
};
