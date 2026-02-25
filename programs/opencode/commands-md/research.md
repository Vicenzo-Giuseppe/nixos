______________________________________________________________________

## description: Enhanced research command with ticket generation, state management, and automatic MD file creation in local .thoughts directory usage: /research <topic> [--deep] [--github] [--web] [--compare] [--ticket] [--stateful] [--md]

# /research - Enhanced Research with Local MD Generation

## NEW CAPABILITIES

### 1. Automatic MD File Creation in .thoughts/

```bash
# Creates comprehensive MD file with all research findings
/research "authentication patterns in Node.js" --md

# Output: .thoughts/authentication-patterns-nodejs-2025-12-29.md
```

### 2. Research with Ticket System

```bash
# Generate ticket and track research state
/research "microservices vs monolith comparison" --ticket --stateful
```

### 3. Intelligent MCP Selection

```bash
# Auto-selects best MCP combination based on query type
/research "GraphQL vs REST performance" --deep

# Comparative research activates multiple MCPs
# Code research focuses on GitHub + EXA
# Company research uses EXA company research + GitHub
```

## ENHANCED RESEARCH WORKFLOW

### Phase 1: Router Analysis

```bash
# Router analyzes query and creates ticket
@Router "analyze: authentication patterns in Node.js --md"

# Router creates:
# - Ticket: RESEARCH-2025-12-29-auth-node
# - MD file: .thoughts/authentication-patterns-nodejs-2025-12-29.md
# - State tracking in .thoughts/tickets/
```

### Phase 2: Intelligent MCP Selection

```bash
# Based on query type, Router selects optimal MCPs
comparative → github + exa + firecrawl + firefox
company → exa_company_research_exa + github + firecrawl
code → github_search_code + exa_get_code_context_exa + firecrawl_extract
documentation → exa_web_search_exa + firefox_mcp_navigate_page + firecrawl_scrape
```

### Phase 3: Coordinated Research

```bash
# Researcher executes with state updates
@Researcher "execute comparative research: authentication patterns --ticket RESEARCH-2025-12-29-auth-node --md"

# Updates ticket state: researching → analyzing → documenting
# Writes findings directly to .thoughts/authentication-patterns-nodejs-2025-12-29.md
```

## AUTOMATIC MD FILE GENERATION

### Final MD File Structure

````markdown
# Research: Authentication Patterns in Node.js

**Date:** 2025-12-29  
**Research ID:** RESEARCH-2025-12-29-auth-node  
**MCPs Used:** github,exa,firecrawl,firefox  
**Status:** Completed  
**Researcher:** Researcher Agent  

## Executive Summary
[2-3 sentence summary of findings]

## Research Questions Answered
- ✅ Current JWT best practices in 2025
- ✅ OAuth2 vs JWT comparison for Node.js  
- ✅ Security vulnerabilities and mitigations
- ✅ Most popular authentication libraries

## GitHub Intelligence
### Repository Analysis
Based on GitHub MCP search_repositories and get_file_contents:
- **Found 46 relevant repositories**
- **Analyzed 12 major implementations**
- **Extracted 8 code patterns**

### Top Repositories
1. **auth0/node-jwt** - 2.3k stars
   - Implementation: JWT with refresh tokens
   - Security: RS256, secure storage
   - Pattern: Middleware-based authentication

2. **jaredhanson/passport** - 21k stars  
   - Implementation: Multi-strategy authentication
   - Security: Session-based with CSRF protection
   - Pattern: Strategy pattern for auth providers

### Code Pattern Analysis
From GitHub MCP search_code results:
```javascript
// Modern JWT pattern (2025)
const authenticate = async (req, res, next) => {
  const token = req.headers.authorization?.split(' ')[1];
  if (!token) return res.status(401).json({ error: 'No token' });
  
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET, {
      algorithms: ['HS256'],
      issuer: 'your-app-name',
      audience: 'your-app-users'
    });
    req.user = decoded;
    next();
  } catch (error) {
    res.status(403).json({ error: 'Invalid token' });
  }
};
````

## Web Research & Best Practices

### External Documentation (EXA MCP)

Based on exa_web_search_exa and crawling_exa:

- **OWASP Authentication Cheat Sheet 2025**
- **Auth0 Node.js Authentication Guide**
- **JWT.io Best Practices**

### Security Recommendations

1. **Use RS256 over HS256** for production
1. **Implement refresh token rotation**
1. **Store tokens in httpOnly cookies**
1. **Add JWT issuer and audience validation**

### Performance Considerations

- JWT verification: ~0.1ms per request
- Session storage: Redis recommended
- Token expiration: 15min access, 7day refresh

## Comparative Analysis

### JWT vs OAuth2 vs Session-Based

| Criteria | JWT | OAuth2 | Session-Based |
|----------|-----|--------|---------------|
| **Stateless** | ✅ | ❌ | ❌ |
| **Scalability** | High | Medium | Low |
| **Security** | Medium | High | High |
| **Complexity** | Low | High | Medium |

### Library Comparison (GitHub Data)

| Library | Stars | Downloads/Week | Security Score |
|--------|-------|-------------|----------------|
| jsonwebtoken | 15.2k | 2.3M | 8.5/10 |
| passport | 21.3k | 1.8M | 9.2/10 |
| express-jwt | 8.1k | 890k | 7.8/10 |
| node-oauth | 3.2k | 234k | 8.0/10 |

## Implementation Recommendations

### For New Projects (2025)

```javascript
// Recommended stack
import jwt from 'jsonwebtoken';
import redis from 'redis';
import { RateLimiterRedis } from 'rate-limiter-flexible';

// Configuration
const config = {
  accessTokenExpiry: '15m',
  refreshTokenExpiry: '7d',
  algorithm: 'RS256',
  issuer: 'your-app',
  audience: 'your-users'
};
```

### Security Checklist

- [ ] Use RS256 algorithm with key rotation
- [ ] Implement refresh token rotation
- [ ] Add rate limiting (5 attempts/minute)
- [ ] Use secure headers (CSP, HSTS)
- [ ] Enable audit logging
- [ ] Add 2FA support

## Code Examples from Research

### Secure JWT Implementation

```javascript
// From GitHub: auth0/node-jwt
export const createTokens = (user) => {
  const accessToken = jwt.sign(
    { userId: user.id, role: user.role },
    privateKey,
    { 
      algorithm: 'RS256',
      expiresIn: '15m',
      issuer: config.issuer,
      audience: config.audience,
      keyid: keyId // For key rotation
    }
  );
  
  const refreshToken = jwt.sign(
    { userId: user.id, tokenType: 'refresh' },
    refreshSecret,
    { expiresIn: '7d' }
  );
  
  return { accessToken, refreshToken };
};
```

### Middleware Pattern

```javascript
// From GitHub: express-jwt example
export const requireAuth = (roles = []) => {
  return async (req, res, next) => {
    const token = req.cookies.accessToken;
    
    if (!token) {
      return res.status(401).json({ error: 'Authentication required' });
    }
    
    try {
      const decoded = jwt.verify(token, publicKey, {
        algorithms: ['RS256'],
        issuer: config.issuer,
        audience: config.audience
      });
      
      if (roles.length && !roles.includes(decoded.role)) {
        return res.status(403).json({ error: 'Insufficient permissions' });
      }
      
      req.user = decoded;
      next();
    } catch (error) {
      if (error.name === 'TokenExpiredError') {
        return res.status(401).json({ error: 'Token expired', code: 'TOKEN_EXPIRED' });
      }
      return res.status(403).json({ error: 'Invalid token' });
    }
  };
};
```

## Source Verification

### GitHub Repositories Analyzed

- [auth0/node-jwt](https://github.com/auth0/node-jwt) - 2.3k stars
- [jaredhanson/passport](https://github.com/jaredhanson/passport) - 21k stars
- [auth0/express-jwt](https://github.com/auth0/express-jwt) - 8.1k stars
- [jwalton/node-oauth](https://github.com/jwalton/node-oauth) - 3.2k stars

### External Documentation

- [OWASP Authentication Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html)
- [JWT.io Best Practices](https://jwt.io/introduction)
- [Auth0 Node.js Authentication](https://auth0.com/docs/quickstart/backend/nodejs)
- [Node.js Security Checklist](https://nodejs.org/en/docs/guides/security/)

### Research Tools Used

- **GitHub MCP**: Repository analysis, code search, file extraction
- **EXA MCP**: Web search, code context, company research
- **Firecrawl MCP**: Documentation scraping, structured extraction
- **Firefox MCP**: Web navigation, snapshot capture

______________________________________________________________________

**Research completed:** $(date)\
**Ticket:** RESEARCH-2025-12-29-auth-node\
**Next steps:** Implement recommended stack, add refresh token rotation, set up audit logging

````

## COMMANDS

### Basic Research with MD Generation
```bash
/research "authentication patterns in Node.js" --md
````

### Comparative Research

```bash
/research "JWT vs OAuth2 vs Session-based authentication" --compare --md
```

### Company Tech Stack Research

```bash
/research "Netflix authentication architecture" --deep --md
```

### Research with Ticket Tracking

```bash
/research "microservices authentication patterns" --ticket --stateful --md
```

## ENHANCED AGENT INTEGRATION

### Router → Researcher → Writer Flow

```bash
# Router analyzes and routes
@Router "research authentication patterns --md"

# Researcher executes with ticket
@Researcher "execute research with ticket RESEARCH-2025-12-29-auth-node --md"

# Writer finalizes document
@Writer "finalize research document for ticket RESEARCH-2025-12-29-auth-node"

# Final output: .thoughts/authentication-patterns-nodejs-2025-12-29.md
```

## LOCAL THOUGHTS INTEGRATION

All research outputs are stored locally in `.thoughts/`:

- **Research documents**: `.thoughts/(subject)-(date).md`
- **Ticket tracking**: `.thoughts/tickets/(pending|active|completed)/`
- **Research index**: `.thoughts/indexes/research_topics.md`
- **MCP usage logs**: `.thoughts/indexes/mcp_usage.log`
