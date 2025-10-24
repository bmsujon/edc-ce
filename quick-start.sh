#!/usr/bin/env bash
#
# Quick Start Script for sovity EDC-CE Local Demo
# This script helps you quickly set up and test the EDC connectors
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored messages
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_header() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

# Check prerequisites
check_prerequisites() {
    print_header "Checking Prerequisites"
    
    # Check Docker
    if command -v docker &> /dev/null; then
        print_success "Docker is installed"
        docker --version
    else
        print_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    
    # Check Docker Compose
    if docker compose version &> /dev/null; then
        print_success "Docker Compose is available"
        docker compose version
    else
        print_error "Docker Compose is not available. Please install Docker Compose."
        exit 1
    fi
    
    # Check if Docker is running
    if docker info &> /dev/null; then
        print_success "Docker daemon is running"
    else
        print_error "Docker daemon is not running. Please start Docker."
        exit 1
    fi
    
    # Check curl
    if command -v curl &> /dev/null; then
        print_success "curl is installed"
    else
        print_warning "curl is not installed. You won't be able to test APIs easily."
    fi
    
    # Check jq (optional)
    if command -v jq &> /dev/null; then
        print_success "jq is installed (for pretty JSON output)"
    else
        print_warning "jq is not installed (optional, but recommended for JSON formatting)"
    fi
}

# Start the demo
start_demo() {
    print_header "Starting sovity EDC-CE Demo"
    
    cd docs/deployment-guide/goals/local-demo-ce || exit 1
    
    print_info "Pulling Docker images..."
    docker compose pull
    
    print_info "Starting services..."
    docker compose up -d
    
    print_info "Waiting for services to be ready (this may take 60 seconds)..."
    sleep 10
    
    # Wait for provider to be healthy
    print_info "Checking provider connector health..."
    for i in {1..30}; do
        if curl -s http://localhost:11000/api/check/health &> /dev/null; then
            print_success "Provider connector is healthy!"
            break
        fi
        if [ $i -eq 30 ]; then
            print_warning "Provider connector health check timed out"
        fi
        sleep 2
    done
    
    # Wait for consumer to be healthy
    print_info "Checking consumer connector health..."
    for i in {1..30}; do
        if curl -s http://localhost:22000/api/check/health &> /dev/null; then
            print_success "Consumer connector is healthy!"
            break
        fi
        if [ $i -eq 30 ]; then
            print_warning "Consumer connector health check timed out"
        fi
        sleep 2
    done
}

# Show access information
show_access_info() {
    print_header "Access Information"
    
    echo "🌐 Web Interfaces:"
    echo ""
    echo "  Provider Connector UI:"
    echo "    URL: http://localhost:11000"
    echo "    Participant ID: provider"
    echo ""
    echo "  Consumer Connector UI:"
    echo "    URL: http://localhost:22000"
    echo "    Participant ID: consumer"
    echo ""
    echo "🔑 API Credentials:"
    echo ""
    echo "  Management API Key: SomeOtherApiKey"
    echo ""
    echo "📡 API Endpoints:"
    echo ""
    echo "  Provider Management API: http://localhost:11000/api/management"
    echo "  Consumer Management API: http://localhost:22000/api/management"
    echo ""
    echo "🐳 Docker Commands:"
    echo ""
    echo "  View logs:     docker compose logs -f"
    echo "  Stop services: docker compose down"
    echo "  Restart:       docker compose restart"
    echo ""
}

# Quick API test
quick_api_test() {
    print_header "Running Quick API Test"
    
    cd docs/deployment-guide/goals/local-demo-ce || exit 1
    
    print_info "Testing Provider API..."
    if curl -s -H "X-Api-Key: SomeOtherApiKey" \
        http://localhost:11000/api/management/v3/assets \
        | grep -q "@context"; then
        print_success "Provider API is responding correctly"
    else
        print_warning "Provider API test failed or returned unexpected response"
    fi
    
    print_info "Testing Consumer API..."
    if curl -s -H "X-Api-Key: SomeOtherApiKey" \
        http://localhost:22000/api/management/v3/assets \
        | grep -q "@context"; then
        print_success "Consumer API is responding correctly"
    else
        print_warning "Consumer API test failed or returned unexpected response"
    fi
}

# Create sample asset
create_sample_asset() {
    print_header "Creating Sample Asset on Provider"
    
    cd docs/deployment-guide/goals/local-demo-ce || exit 1
    
    print_info "Creating asset: weather-data-api"
    
    RESPONSE=$(curl -s -X POST http://localhost:11000/api/management/v3/assets \
        -H "X-Api-Key: SomeOtherApiKey" \
        -H "Content-Type: application/json" \
        -d '{
            "@context": {
                "edc": "https://w3id.org/edc/v0.0.1/ns/"
            },
            "@type": "Asset",
            "@id": "weather-data-api",
            "properties": {
                "name": "Weather Data API",
                "description": "Real-time weather data from public API",
                "contenttype": "application/json"
            },
            "dataAddress": {
                "@type": "DataAddress",
                "type": "HttpData",
                "baseUrl": "https://api.open-meteo.com/v1/forecast?latitude=52.52&longitude=13.41&current_weather=true",
                "method": "GET"
            }
        }')
    
    if echo "$RESPONSE" | grep -q "@id"; then
        print_success "Asset created successfully!"
        if command -v jq &> /dev/null; then
            echo "$RESPONSE" | jq .
        fi
    else
        print_warning "Asset might already exist or creation failed"
        echo "$RESPONSE"
    fi
    
    print_info "Creating unrestricted access policy..."
    curl -s -X POST http://localhost:11000/api/management/v3/policydefinitions \
        -H "X-Api-Key: SomeOtherApiKey" \
        -H "Content-Type: application/json" \
        -d '{
            "@context": {
                "edc": "https://w3id.org/edc/v0.0.1/ns/",
                "odrl": "http://www.w3.org/ns/odrl/2/"
            },
            "@type": "PolicyDefinitionDto",
            "@id": "unrestricted-policy",
            "policy": {
                "@type": "Policy",
                "odrl:permission": [{
                    "odrl:action": "USE"
                }]
            }
        }' &> /dev/null
    print_success "Policy created!"
    
    print_info "Creating contract definition..."
    curl -s -X POST http://localhost:11000/api/management/v3/contractdefinitions \
        -H "X-Api-Key: SomeOtherApiKey" \
        -H "Content-Type: application/json" \
        -d '{
            "@context": {
                "edc": "https://w3id.org/edc/v0.0.1/ns/"
            },
            "@type": "ContractDefinition",
            "@id": "weather-contract-def",
            "accessPolicyId": "unrestricted-policy",
            "contractPolicyId": "unrestricted-policy",
            "assetsSelector": [{
                "@type": "Criterion",
                "operandLeft": "https://w3id.org/edc/v0.0.1/ns/id",
                "operator": "=",
                "operandRight": "weather-data-api"
            }]
        }' &> /dev/null
    print_success "Contract definition created!"
    
    echo ""
    print_success "Sample data offer is now published!"
    echo ""
    echo "You can now:"
    echo "  1. Browse the catalog from consumer: http://localhost:22000"
    echo "  2. Search for provider endpoint: http://provider/api/v1/dsp?participantId=provider"
    echo "  3. You should see the 'Weather Data API' offer"
}

# View logs
view_logs() {
    print_header "Viewing Service Logs"
    
    cd docs/deployment-guide/goals/local-demo-ce || exit 1
    
    print_info "Showing logs (Press Ctrl+C to exit)..."
    docker compose logs -f
}

# Stop demo
stop_demo() {
    print_header "Stopping sovity EDC-CE Demo"
    
    cd docs/deployment-guide/goals/local-demo-ce || exit 1
    
    print_info "Stopping services..."
    docker compose down
    
    print_success "Services stopped!"
}

# Clean demo (remove volumes)
clean_demo() {
    print_header "Cleaning sovity EDC-CE Demo"
    
    cd docs/deployment-guide/goals/local-demo-ce || exit 1
    
    print_warning "This will remove all data (database volumes)"
    read -p "Are you sure? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "Stopping and removing services and volumes..."
        docker compose down -v
        print_success "Cleanup complete!"
    else
        print_info "Cleanup cancelled"
    fi
}

# Show menu
show_menu() {
    clear
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "              sovity EDC-CE Quick Start Menu                      "
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "  1) Start Demo (Full Setup)"
    echo "  2) Start Demo (Quick - skip checks)"
    echo "  3) Create Sample Asset & Contract"
    echo "  4) Show Access Info"
    echo "  5) Test APIs"
    echo "  6) View Logs"
    echo "  7) Stop Demo"
    echo "  8) Clean Demo (remove all data)"
    echo "  9) Exit"
    echo ""
    echo -n "Select an option (1-9): "
}

# Main menu loop
main_menu() {
    while true; do
        show_menu
        read -r choice
        
        case $choice in
            1)
                check_prerequisites
                start_demo
                show_access_info
                quick_api_test
                echo ""
                read -p "Press Enter to continue..."
                ;;
            2)
                start_demo
                show_access_info
                echo ""
                read -p "Press Enter to continue..."
                ;;
            3)
                create_sample_asset
                echo ""
                read -p "Press Enter to continue..."
                ;;
            4)
                show_access_info
                echo ""
                read -p "Press Enter to continue..."
                ;;
            5)
                quick_api_test
                echo ""
                read -p "Press Enter to continue..."
                ;;
            6)
                view_logs
                ;;
            7)
                stop_demo
                echo ""
                read -p "Press Enter to continue..."
                ;;
            8)
                clean_demo
                echo ""
                read -p "Press Enter to continue..."
                ;;
            9)
                print_info "Goodbye!"
                exit 0
                ;;
            *)
                print_error "Invalid option. Please try again."
                sleep 2
                ;;
        esac
    done
}

# Check if script is run with arguments
if [ $# -eq 0 ]; then
    # No arguments, show interactive menu
    main_menu
else
    # Arguments provided, run specific command
    case "$1" in
        start)
            check_prerequisites
            start_demo
            show_access_info
            ;;
        quick-start)
            start_demo
            show_access_info
            ;;
        sample)
            create_sample_asset
            ;;
        test)
            quick_api_test
            ;;
        info)
            show_access_info
            ;;
        logs)
            view_logs
            ;;
        stop)
            stop_demo
            ;;
        clean)
            clean_demo
            ;;
        *)
            echo "Usage: $0 [start|quick-start|sample|test|info|logs|stop|clean]"
            echo ""
            echo "Commands:"
            echo "  start        - Full start with prerequisite checks"
            echo "  quick-start  - Quick start without checks"
            echo "  sample       - Create sample asset and contract"
            echo "  test         - Test API connectivity"
            echo "  info         - Show access information"
            echo "  logs         - View service logs"
            echo "  stop         - Stop all services"
            echo "  clean        - Stop and remove all data"
            echo ""
            echo "Or run without arguments for interactive menu"
            exit 1
            ;;
    esac
fi
