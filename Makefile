.PHONY: ci-wb ci-post-wb


# Arguments:
# v:   macOS version 
# 	   values: 13 or 14
#
# env: environment
# 	   values: prod for production, anything else for preproduction

# Usage examples:
# make ci-wb v=13 env=prod
# make ci-post-wb v=14 env=prod
# make ci-wb v=14

ci-wb:
	ifndef v
		$(error v is not set)
	endif
	@echo "Building for macOS-$(v).arm64.tart"
	@sh scripts/macos/macOS-$(v).arm64.tart.build.sh

ci-post-wb:
	ifndef env
		$(error env is not set)
	endif

	ifndef v
		$(error v is not set)
	endif

	@echo "Pushing to macOS-$(v).arm64.tart for [$(env)]";
	@sh scripts/macos/macOS.arm64.tart.push.sh --warp-env=$(env) --mac-version=$(v);