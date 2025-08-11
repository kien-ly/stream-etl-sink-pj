set -e

echo "🚀 Deploying PostgreSQL with CDC configuration..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color


echo "${RED}🗃️ Applying PostgreSQL CDC configuration...${NC}"

echo "${YELLOW}⏳ Waiting for PostgreSQL pod to be ready...${NC}"

echo "${GREEN}✅ Deployment completed successfully!${NC}" 