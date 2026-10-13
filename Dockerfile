# Use the official Julia base image
FROM julia:1.11.1

# Set up the global Julia environment
WORKDIR /tmp

# Copy the Project.toml and Manifest.toml into the global environment
COPY . /tmp

# Preinstall the dependencies in the global environment
RUN julia --project=. -e "using Pkg; Pkg.instantiate(); Pkg.precompile(); Pkg.test();"

# Set the default working directory for the container
WORKDIR /workdir

# Expose port 8000 for Documenter
EXPOSE 8000

# Set the default command
CMD ["julia", "--project=."]